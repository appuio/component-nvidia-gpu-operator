local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local operatorlib = import 'lib/openshift4-operators.libsonnet';

local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.nvidia_gpu_operator;

local nfd_operator_group = operatorlib.OperatorGroup('openshift-nfd') {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-wave': '-90',
    },
    namespace: params.feature_discovery_operator.namespace,
    generateName: "openshift-nfd-"
  },
  spec+: {
    targetNamespaces: [
      params.feature_discovery_operator.namespace,
    ],
  },
};

local nfd_operator_subscription = operatorlib.namespacedSubscription(
  params.feature_discovery_operator.namespace,
  'nfd',
  params.feature_discovery_operator.olm.channel,
  'redhat-operators'
) {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-wave': '-80',
    },
  },
};

local operator_group = operatorlib.OperatorGroup('nvidia-gpu-operator-group') {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-wave': '-90',
    },
    namespace: params.gpu_operator.namespace,
  },
  spec+: {
    targetNamespaces: [
      params.gpu_operator.namespace,
    ],
  },
};

local operator_subscription = operatorlib.namespacedSubscription(
  params.gpu_operator.namespace,
  'gpu-operator-certified',
  params.gpu_operator.olm.channel,
  'certified-operators'
) {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-wave': '-80',
    },
  },
};

{
  [if params.install_method == 'olm' && params.feature_discovery_operator.enabled then '10_nfd_operator_group']: nfd_operator_group,
  [if params.install_method == 'olm' && params.feature_discovery_operator.enabled then '10_nfd_operator_subscription']: nfd_operator_subscription,
  [if params.install_method == 'olm' then '10_gpu_operator_group']: operator_group,
  [if params.install_method == 'olm' then '10_gpu_operator_subscription']: operator_subscription,
}
