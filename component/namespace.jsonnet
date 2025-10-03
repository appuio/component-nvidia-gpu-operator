local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';

local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.nvidia_gpu_operator;


// Define outputs below
{
  '00_gpu_namespace': kube.Namespace(params.operator.namespace) {
    metadata+: {
      annotations+: {
        // Allow pods to be scheduled on any node
        'openshift.io/node-selector': '',
      },
      labels+: {
        'openshift.io/cluster-monitoring': 'true',
      },
    },
  },
  '00_nfd_namespace': kube.Namespace(params.nfd.namespace) {
    metadata+: {
      annotations+: {
        // Allow pods to be scheduled on any node
        'openshift.io/node-selector': '',
      },
      labels+: {
        'openshift.io/cluster-monitoring': 'true',
      },
    },
  },
}
