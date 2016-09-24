#!/usr/bin/env python

import odoorpc
import os

ODOO_SUPER_PASSWORD = os.getenv("ODOO_SUPER_PASSWORD", "admin")

ODOO_HOST = os.getenv("ODOO_HOST", "localhost")
ODOO_PORT = os.getenv("ODOO_PORT", 8069)

ODOO_DATABASE_NAME = os.getenv("ODOO_DATABASE_NAME", "demo")
ODOO_ADMIN_EMAIL = os.getenv("ODOO_ADMIN_EMAIL", "admin@local.host")
ODOO_ADMIN_PASSWORD = os.getenv("ODOO_ADMIN_PASSWORD", "password")

ODOO_LANG = os.getenv("ODOO_LANG", "en_US")
ODOO_COMPANY = os.getenv("ODOO_COMPANY", "Demo")
ODOO_TIMEZONE = os.getenv("ODOO_TIMEZONE", "Asia/Singapore")

ODOO_INSTALL_MODULES = os.getenv("ODOO_INSTALL_MODULES", "")
ODOO_UNINSTALL_MODULES = os.getenv("ODOO_UNINSTALL_MODULES", "")

def get_session(login=True):

    odoo = odoorpc.ODOO(ODOO_HOST, port=ODOO_PORT)
    odoo.config['timeout'] = None

    if login:
        odoo.login(ODOO_DATABASE_NAME, "admin", ODOO_ADMIN_PASSWORD)

    return odoo


def create_database():

    odoo = get_session(login=False)

    if ODOO_DATABASE_NAME not in odoo.db.list():
        print "Creating Database '" + ODOO_DATABASE_NAME + "'"
        odoo.db.create(ODOO_SUPER_PASSWORD, ODOO_DATABASE_NAME, demo=False, lang=ODOO_LANG, admin_password=ODOO_ADMIN_PASSWORD)
        print "Creating Done"
    else:
        print "Dateabase '" + ODOO_DATABASE_NAME + "' already exists"


def uninstall_modules():

    odoo = get_session()
    Module = odoo.env["ir.module.module"]

    uninstall_modules = ODOO_UNINSTALL_MODULES.split(", ")
    print "Module to uninstall"
    print uninstall_modules

    for module_name in uninstall_modules:
        module_ids = Module.search([("name", "=", [module_name])])
        for module in Module.browse(module_ids):
            if module.state == "installed" or \
               module.state == "to upgrade" or \
               module.state == "to remove" or \
               module.state == "to install":
                print "Uninstalling Module '" + module_name + "'"
                Module.button_immediate_uninstall(module_ids)
                print "Uninstalling Done"


def update_company():

    odoo = get_session()
    company = odoo.env.user.company_id
    print "Setting Company to '" + ODOO_COMPANY +"'"
    company.name = ODOO_COMPANY
    print "Setting Done"


def update_admin_user():

    odoo = get_session()
    admin = odoo.env.user

    print "Configuring Admin User"

    group_technical_feature = odoo.env.ref("base.group_no_one")
    #group_sales_manager = odoo.env.ref("base.group_sales_manager")

    if group_technical_feature not in admin.groups_id:
        admin.groups_id += group_technical_feature

    #if group_sales_manager not in admin.groups_id:
    #    admin.groups_id += group_sales_manager

    if not admin.tz:
        admin.tz = ODOO_TIMEZONE

    print "Configuring Done"


def install_modules():

    odoo = get_session()
    Module = odoo.env["ir.module.module"]

    install_modules = ODOO_INSTALL_MODULES.split(", ")
    print "Module to install"
    print install_modules

    for module_name in install_modules:
        module_ids = Module.search([("name", "=", [module_name])])
        for module in Module.browse(module_ids):
            if module.state == "installed":
                print "Module '" + module.name + "' has already been installed"
            else:
                print "Installing Module '" + module.name + "' ..."
                Module.button_immediate_install(module_ids)
                print "Installing Done"


def main():

    create_database()
    uninstall_modules()
    update_company()
    update_admin_user()
    install_modules()

if __name__ == "__main__":
    main()
