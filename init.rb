# For Restful Auth piece
require File.join(File.dirname(__FILE__), 'lib', 'restful_authentication', 'authentication')
require File.join(File.dirname(__FILE__), 'lib', 'restful_authentication', 'authentication', 'by_password')
require File.join(File.dirname(__FILE__), 'lib', 'restful_authentication', 'authentication', 'by_cookie_token')

# For Slave Engine additions
require File.join(File.dirname(__FILE__), 'lib', 'slave_engine')