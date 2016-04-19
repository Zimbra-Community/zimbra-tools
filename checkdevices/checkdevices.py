""" Check currently registered devices in Zimbra and reported unapproved
devices """
import argparse
from cement.core.controller import CementBaseController, expose
from cement.core.foundation import CementApp
from pythonzimbra.communication import Communication
from pythonzimbra.tools import auth
from pythonzimbra.tools.dict import get_value
import re


class CheckDevicesController(CementBaseController):

    url = ""

    """ Admin-URL """

    user_url = ""

    """ User-URL """

    token = ""

    """ Admin-Token """

    preauth_cache = {}

    """ A cache of preauth keys """

    class Meta:

        label = "base"
        description = "Check currently registered devices in Zimbra and " \
                      "report unapproved devices"
        arguments = [
            (
                ["-H", "--host"],
                {
                    "help": "Zimbra-Host",
                    "required": True
                }
            ),
            (
                ["-u", "--user"],
                {
                    "help": "Admin user to use",
                    "required": True
                }
            ),
            (
                ["-p", "--passwordfile"],
                {
                    "help": "A file containing the password for the admin.",
                    "type": argparse.FileType("r")
                }
            ),
            (
                ["--password"],
                {
                    "help": "Password for the admin user (not "
                            "recommended, please use "
                            "-p/--passwordfile instead)",
                    "default": ""
                }
            ),
            (
                ["-s", "--scope"],
                {
                    "help": "Scope to scan. Possible values: "
                            "DOMAIN=<domain>, LIST=<list>, USER=<user>. "
                            "Defaults to the domain of the admin user.",
                    "default": ""
                }
            ),
            (
                ["-a", "--approved"],
                {
                    "help": "Path to approved-configuration file",
                    "default": "approved.conf",
                    "type": argparse.FileType("r")
                }
            ),
            (
                ["-U", "--url"],
                {
                    "help": "Zimbra SOAP-URL (if not "
                            "https://<host>:7071/service/admin/soap)",
                    "default": ""
                }
            ),
            (
                ["--user-url"],
                {
                    "help": "Zimbra SOAP-URL for user request (if not "
                            "https://<host>/service/soap)",
                    "default": ""
                }
            )
        ]

    @expose(hide=True)
    def default(self):

        self.app.log.debug("Starting process.")

        self.url = self.app.pargs.url

        if self.url == "":

            self.url = "https://%s:7071/service/admin/soap" % \
                       self.app.pargs.host

        self.user_url = self.app.pargs.user_url

        if self.user_url == "":

            self.user_url = "https://%s/service/soap" % self.app.pargs.host

        if self.app.pargs.passwordfile:

            password = self.app.pargs.passwordfile.read().strip()

        else:

            password = self.app.pargs.password

        self.token = auth.authenticate(
            self.url,
            self.app.pargs.user,
            password,
            admin_auth=True
        )

        if self.token is None:

            self.app.log.fatal("Cannot login into zimbra")
            exit(1)

        # Read in approved file

        approved = self._read_approved()

        # Read in users

        userlist = self._get_scope()

        disapproved = {}

        for user in userlist:

            # Fetch the devices of the user

            devices = self._get_devices(user)

            # Check against approved devices

            for device in devices:

                found = False

                for approved_test in approved:

                    if re.search(approved_test["value"], device[
                            approved_test["selector"]]):

                        found = True

                if not found:

                    self.app.log.debug("Found disapproved device: %s" % device)

                    # Add device to the disapproved list

                    if user not in disapproved.keys():

                        disapproved[user] = []

                    disapproved[user].append(device)

        if len(disapproved.keys()) > 0:

            for key in disapproved.keys():

                print "=== %s ===\n" % key

                for device in disapproved[key]:

                    for device_key in device.keys():

                        print "%s: %s" % (device_key, device[device_key])

                    print ""

    def _read_approved(self):

        approved_lines = self.app.pargs.approved.read()

        self.app.pargs.approved.close()

        approved = []

        for line in approved_lines.split("\n"):

            if re.search("^\s*#", line):

                # Filter comments

                continue

            if re.search("^\s*$", line):

                # Filter empty lines

                continue

            matches = re.search("^([^=]*)=(.*)$", line)

            if not matches:

                self.app.log.fatal("Cannot interpret line %s" % line)

                exit(1)

            selector = matches.group(1)
            value = matches.group(2)

            approved.append({
                "selector": selector,
                "value": value
            })

        return approved

    def _get_devices(self, user):

        self.app.log.debug("Fetching devices of user %s" % user)

        (local_part, domain_part) = user.split("@")

        if domain_part not in self.preauth_cache:

            # No preauth key cached. Fetch one

            self.app.log.debug("Fetch preauth key for domain %s" % domain_part)

            comm = Communication(self.url)

            preauthkey_request = comm.gen_request(token=self.token)

            preauthkey_request.add_request(
                "GetDomainRequest",
                {
                    "domain": {
                        "by": "name",
                        "_content": domain_part
                    }
                },
                "urn:zimbraAdmin"
            )

            preauthkey_response = comm.send_request(preauthkey_request)

            if preauthkey_response.is_fault():

                self.app.log.fatal(
                    "Cannot fetch preauth key for domain %s" % domain_part,
                    preauthkey_response.get_fault_code(),
                    preauthkey_response.get_fault_message(),
                )

                exit(1)

            preauth = get_value(
                preauthkey_response.get_response()["GetDomainResponse"][
                    "domain"]["a"],
                "zimbraPreAuthKey"
            )

            if preauth is None:

                self.app.log.fatal(
                    "Domain %s has no preauthkey. Please use zmprov gdpak "
                    "<domain> first." % domain_part
                )

                exit(1)

            self.preauth_cache[domain_part] = preauth

        else:

            preauth = self.preauth_cache[domain_part]

        user_token = auth.authenticate(
            self.user_url,
            user,
            preauth
        )

        if user_token is None:

            self.app.log.fatal("Cannot login as user %s" % user)

            exit(1)

        user_comm = Communication(self.user_url)

        get_device_status_request = user_comm.gen_request(token=user_token)

        get_device_status_request.add_request(
            "GetDeviceStatusRequest",
            {},
            "urn:zimbraSync"
        )

        get_device_status_response = user_comm.send_request(
            get_device_status_request)

        if get_device_status_response.is_fault():

            self.app.log.fatal(
                "Cannot fetch devices for user %s: (%s) %s" % (
                    user,
                    get_device_status_response.get_fault_code(),
                    get_device_status_response.get_fault_message()
                )
            )

            exit(1)

        devices = []

        if "device" in get_device_status_response.get_response()[
                "GetDeviceStatusResponse"]:

            devices = get_device_status_response.get_response()[
                "GetDeviceStatusResponse"]["device"]

        if type(devices) == dict:

            devices = [devices]

        return devices

    def _get_scope(self):

        """ Build up a list of users for the specified scope
        """

        self.app.log.debug("Building up user list of scope definition")

        if self.app.pargs.scope == "":

            # Set the scope to the admin user's domain

            (local_part, domain_part) = self.app.pargs.user.split("@")

            scope_config = "DOMAIN=%s" % domain_part

        else:

            scope_config = self.app.pargs.scope

        (scope, scope_value) = scope_config.split("=")

        if scope not in ("DOMAIN", "LIST", "USER"):

            self.app.log.fatal("Scope not correctly configured. Please use "
                               "DOMAIN, LIST or USER")
            exit(1)

        userlist = []

        if scope == "DOMAIN":

            # Fetch all users in a domain

            self.app.log.debug(
                "Searching for accounts in domain %s" % scope_value
            )

            comm = Communication(self.url)
            search_account_request = comm.gen_request(token=self.token)

            search_account_request.add_request(
                "SearchAccountsRequest",
                {
                    "query": "",
                    "domain": scope_value
                },
                "urn:zimbraAdmin"
            )

            search_account_response = comm.send_request(search_account_request)

            if search_account_response.is_fault():

                self.app.log.fatal(
                    "Cannot search for accounts in the specified domain %s: "
                    "(%s) %s" % (
                        scope_value,
                        search_account_response.get_fault_code(),
                        search_account_response.get_fault_message()
                    )
                )

            for account in search_account_response.get_response()[
                    "SearchAccountsResponse"]["account"]:

                userlist.append(account["name"])

        elif scope == "LIST":

            # Fetch all users in a distribution list

            self.app.log.debug(
                "Searching for users in distribution list %s" % scope_value
            )

            comm = Communication(self.url)
            get_distributionlist_request = comm.gen_request(token=self.token)

            get_distributionlist_request.add_request(
                "GetDistributionListRequest",
                {
                    "dl": {
                        "by": "name",
                        "_content": scope_value
                    }
                },
                "urn:zimbraAdmin"
            )

            get_distributionlist_response = comm.send_request(
                get_distributionlist_request
            )

            if get_distributionlist_response.is_fault():

                self.app.log.fatal(
                    "Cannot search for accounts in the specified list %s: "
                    "(%s) %s" % (
                        scope_value,
                        get_distributionlist_response.get_fault_code(),
                        get_distributionlist_response.get_fault_message()
                    )
                )

            for member in get_distributionlist_response.get_response()[
                    "GetDistributionListResponse"]["dl"]["dlm"]:

                if type(member) == dict:

                    userlist.append(member["_content"])

                else:

                    userlist.append(member)

        elif scope == "USER":

            # Just a single user

            userlist.append(scope_value)

        self.app.log.debug("Found these users:\n %s" % userlist)

        return userlist


class CheckDevicesApp(CementApp):

    class Meta:

        label = "checkdevices"
        base_controller = CheckDevicesController


app = CheckDevicesApp()

app.setup()
app.run()
app.close()
