#!/bin/bash

# Get the current date and time
current_datetime=$(date '+%Y%m%d-%H%M%S')

# Create a backup directory named pv-(current date+time)
backup_dir="dir-${current_datetime}"
mkdir -p "${backup_dir}"

# Retrieve list of PV names containing the string "notebook"
pv_names=$(kubectl get pv | grep ml-fabric-stage-1-notebooks | awk '{print $1}')
# pv_names=$(kubectl get pv | grep notebooks | awk '{print $1}')

# Function to backup PV to YAML
backup_pv() {
    local pv_name=$1
    kubectl get pv "${pv_name}" -o yaml > "${backup_dir}/pv-${pv_name}.yaml"
    if [[ $? -eq 0 ]]; then
        echo "Backed up PV ${pv_name} to ${backup_dir}/pv-${pv_name}.yaml"
    else
        echo "Failed to backup PV ${pv_name}"
    fi
}

# Function to backup PVC to YAML
backup_pvc() {
    local pvc_name=$1
    local pvc_namespace=$2
    kubectl get pvc "${pvc_name}" -n "${pvc_namespace}" -o yaml > "${backup_dir}/pvc-${pvc_name}-${pvc_namespace}.yaml"
    if [[ $? -eq 0 ]]; then
        echo "Backed up PVC ${pvc_name} in namespace ${pvc_namespace} to ${backup_dir}/pvc-${pvc_name}-${pvc_namespace}.yaml"
    else
        echo "Failed to backup PVC ${pvc_name} in namespace ${pvc_namespace}"
    fi
}

# Function to remove finalizer from PV
# remove_finalizer() {
#     local pv_name=$1
#     kubectl patch pv "${pv_name}" --type=json -p '[{"op":"remove","path":"/metadata/finalizers"}]'
#     if [[ $? -eq 0 ]]; then
#         echo "Removed finalizer from PV ${pv_name}"
#     else
#         echo "Failed to remove finalizer from PV ${pv_name}"
#     fi
# }

# Backup each PV and its associated PVC, then remove the PV's finalizer
for pv_name in ${pv_names}; do
    backup_pv "${pv_name}"
    
    # Retrieve the associated PVC information from the PV
    pvc_name=$(kubectl get pv "${pv_name}" -o jsonpath='{.spec.claimRef.name}')
    pvc_namespace=$(kubectl get pv "${pv_name}" -o jsonpath='{.spec.claimRef.namespace}')
    
    # Backup the associated PVC
    if [[ -n "${pvc_name}" && -n "${pvc_namespace}" ]]; then
        backup_pvc "${pvc_name}" "${pvc_namespace}"
    else
        echo "No associated PVC found for PV ${pv_name}"
    fi
    
    # remove_finalizer "${pv_name}"
done

