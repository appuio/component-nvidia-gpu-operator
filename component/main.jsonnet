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

local nfd = NodeFeatureDiscovery(params.feature_discovery_operator.nodeFeatureDiscovery.name) {
    metadata+: {
        namespace: params.feature_discovery_operator.namespace,
    },
    spec+: params.feature_discovery_operator.nodeFeatureDiscovery.spec,
  } {
    spec+: {
      workerConfig: {
        configData: std.manifestYamlDoc(params.feature_discovery_operator.configData),
      },
    },
  };

local clusterpolicy = ClusterPolicy(params.gpu_operator.cluster_policy_name) {
    spec+: params.gpu_operator.cluster_policy_spec
};


// Define outputs below
{
    '20_nfd': nfd,
    '30_clusterpolicy': clusterpolicy,
}
