#
# Description: 
#       Raven API Configuration File
# Version: 
#       v2.3.0
# Purpose: 
#       Defines parameters required to configure the Raven API Helper library for
#       use by an individual client.
# Usage: 
#       Place in same deployment directory as Raven API Helper library "Raven.rb"
# Notes: 
#       As written points to the demonstration system, adjust as needed. 
# See: 
#       For full documentation see "http://docs.deepcovelabs.com/raven/api-guide/" 
#
 
# The client on whose behalf requests are being submitted.
# Use "ernest" for testing, change to your supplied contact Id for production.
RAVEN_USERNAME = "ernest" 

# The client's shared secret, used to authenticate requests.
# Use "all good men die young" for testing, change to your supplied shared secret for production.
RAVEN_SECRET = "all good men die young"

# The demonstration system gateway.
# Uncomment line below for testing.
RAVEN_GATEWAY = "https://demo.pacnetservices.com/realtime"
# The production system gateway.
# Uncomment line below for production.
# RAVEN_GATEWAY = "https://raven.pacnetservices.com/realtime"

# Optional client-supplied text that is appended to each request's unique Id.
# Use "TEST" for testing, change or comment out for production.
RAVEN_PREFIX = "TEST"       # for your use, forms part of unique request ID

# To make the Raven API output debugging information.
# Use "off" for production, turn "on" if required for testing.
RAVEN_DEBUG_OUTPUT = "off"  # on/off

