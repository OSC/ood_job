require 'ood_job/version'
require 'ood_job/node_info'
require 'ood_job/node_request'
require 'ood_job/script'
require 'ood_job/info'
require 'ood_job/status'
require 'ood_job/adapter'

# The main namespace of ood_job
module OodJob
  # A namespace to hold all subclasses of {Adapters}
  module Adapters
    require 'ood_job/adapters/torque'
  end
end
