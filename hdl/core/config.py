# Hack to make python parse the config file:
CONFFILE = "../../.config"
y = True
exec(open(CONFFILE).read())
