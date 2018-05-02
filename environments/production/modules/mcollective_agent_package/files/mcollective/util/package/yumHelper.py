#!/usr/bin/python
import yum
import sys
import json
from yum.rpmtrans import NoOutputCallBack
import logging
from optparse import OptionParser

class YumHelper():
    def __init__(self):
        self.yb = yum.YumBase()

        # Disable logging
        self.yb.preconf.debuglevel = 0
        self.yb.preconf.errorlevel = 0
        self.yb.verbose_logger = logging.getLogger()

        self.yb.doTsSetup()
        self.yb.doRpmDBSetup()

    def _build_dict(self, po):
        pkg_list = []
        for p in po:
            p_dict = { 'status': {
                         'name': p.name,
                         'version': p.version,
                         'release': p.release,
                         'epoch': p.epoch,
                         'arch': p.arch,
                         'provider': 'yum',
                         'ensure': '%s-%s' % (p.version, p.release)
                       }
                     }
            pkg_list.append(p_dict)
        return pkg_list

    def install(self, package):
        try:
            p = self.yb.install(name=package)
            self.yb.buildTransaction()
            self.yb.processTransaction(rpmDisplay=NoOutputCallBack())
            if p:
                p_dict = self._build_dict(p)[0]
            else:
                p_dict = { 'msg': 'already installed and latest version',
                           'status': {} }
        except yum.Errors.InstallError, e:
            p_dict = {'msg': str(e),
                      'status': 'Failed' }
        finally:
            self.yb.closeRpmDB()
        return json.dumps(p_dict, sort_keys=True)

    def remove(self, package):
        try:
            p = self.yb.remove(name=package)
            self.yb.buildTransaction()
            self.yb.processTransaction(rpmDisplay=NoOutputCallBack())
            if p:
                p_dict = self._build_dict(p)[0]
            else:
                p_dict = { 'msg': 'Package not installed',
                           'status': {} }
        except yum.Errors.InstallError, e:
            p_dict = {'msg': str(e),
                      'status': 'Failed' }
        finally:
            self.yb.closeRpmDB()
        return json.dumps(p_dict, sort_keys=True)

    def update(self, package):
        pkg_list = []
        try:
            if package is "*":
                p = self.yb.update()
            else:
                p = self.yb.update(name=package)
            self.yb.buildTransaction()
            self.yb.processTransaction(rpmDisplay=NoOutputCallBack())
            if len(p) > 1:
                p_dict = { 'status': 'Everything updated' }
            elif len(p) == 1:
                p_dict = self._build_dict(p)[0]
            else:
                p_dict = { 'status': 'Everything is up to date' }
        except yum.Errors.InstallError, e:
            p_dict = {'msg': str(e),
                      'status': 'Failed' }
        finally:
            self.yb.closeRpmDB()
        return json.dumps(p_dict, sort_keys=True)

    def status(self, package):
        try:
            p = self.yb.rpmdb.searchNevra(name=package)
            if p:
                p_dict = self._build_dict(p)[0]['status']
            else:
                p_dict = { 'status': 'Not installed' }
        except yum.Errors.InstallError, e:
            p_dict = {'msg': str(e),
                      'status': 'Failed' }
        finally:
            self.yb.closeRpmDB()
        return json.dumps(p_dict, sort_keys=True)

def parse_options():
    parser = OptionParser()

    parser.add_option('-i', '--install', type="string", dest="install",
                     help="Install package")
    parser.add_option('-r', '--remove', type="string", dest="remove",
                     help="Remove package")
    parser.add_option('-s', '--status', type="string", dest="status",
                     help="Status of package")
    parser.add_option('-u', '--update', type="string", dest="update",
                     help="Update package, \"*\" for all ")
    options, args = parser.parse_args()

    if (not options.install and not options.remove
        and not options.update and not options.status):
        parser.error("use --help for help ")

    return options

def main():
    options = parse_options()
    y = YumHelper()
    if options.install:
        print y.install(options.install)
    if options.remove:
        print y.remove(options.remove)
    if options.update:
        print y.update(options.update)
    if options.status:
        print y.status(options.status)
if __name__ == '__main__':
    main()
