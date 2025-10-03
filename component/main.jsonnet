// main template for nvidia-gpu-operator
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.nvidia_gpu_operator;


local NodeFeatureDiscovery = function(name='') {
  apiVersion: 'nfd.openshift.io/v1',
  kind: 'NodeFeatureDiscovery',
  metadata: {
    name: name,
  },
};

local ClusterPolicy = function(name='') {
  apiVersion: 'nvidia.com/v1',
  kind: 'ClusterPolicy',
  metadata: {
    name: name,
  },
};

local nfd = NodeFeatureDiscovery(params.nfd.node_feature_discovery.name) {
    metadata+: {
        namespace: params.nfd.namespace,
    },
    spec+: params.nfd.node_feature_discovery.spec,
  } {
    spec+: {
      workerConfig+: {
        configData: std.manifestYamlDoc(params.nfd.node_feature_discovery.configData),
      },
    },
  };

local clusterpolicy = ClusterPolicy(params.operator.cluster_policy_name) {
    spec+: params.operator.cluster_policy_spec
};


// Define outputs below
{
    [if params.nfd.enabled then '20_nfd']: nfd,
    '30_clusterpolicy': clusterpolicy,
}
