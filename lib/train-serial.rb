libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "train-serial/version"

require "train-serial/transport"
require "train-serial/connection"
