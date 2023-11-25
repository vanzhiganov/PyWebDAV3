from __future__ import absolute_import
import sys
import logging

log = logging.getLogger(__name__)

try:
    import pymysql
except ImportError:
    log.info('No SQL support - MySQLdb missing...')
    pass


class MySQLConnector:
    def connect(self, username, password, host, port, db):
        try:
            connection = pymysql.connect(host=host, port=int(port), user=username, passwd=password, db=db)
        except pymysql.OperationalError as message:
            log.error("%d: %s" % (message.args[0], message.args[1]))
            return 0
        else:
            self.db = connection.cursor()
            return 1

    def execute(self, qry):
        if self.db:
            try:
                res = self.db.execute(qry)
            except pymysql.OperationalError as message:
                log.error("Error %d: %s" % (message.args[0], message.args[1]))
                raise pymysql.OperationalError
            except pymysql.ProgrammingError as message:
                log.error("Error %d: %s" % (message.args[0], message.args[1]))
                raise Exception('mysql', message.args)
            else:
                log.debug('Query Returned '+str(res)+' results')
                return self.db.fetchall()

    def create_user(self, user, passwd):
        qry = "SELECT * FROM Users WHERE User='%s'" % user
        res = self.execute(qry)
        if not res or len(res) == 0:
            qry = "insert into Users (User,Pass) values('%s','%s')" % (user, passwd)
            res = self.execute(qry)
        else:
            log.debug("Username already in use")

    def create_table(self):
        qry = """
        CREATE TABLE `Users` (
            `uid` int(10) NOT NULL auto_increment,
            `User` varchar(60) default NULL,
            `Pass` varchar(60) default NULL,
            `Write` tinyint(1) default '0',
            PRIMARY KEY  (`uid`)
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;
        """
        self.execute(qry)

    def first_run(self, user, passwd):
        res = self.execute('SELECT * FROM Users')
        if res or type(res) == type(()):
            pass
        else:
            self.create_table()
            self.create_user(user, passwd)

    def __init__(self, user, password, host, port, db):
        self.db = None
        self.connect(user, password, host, port, db)
