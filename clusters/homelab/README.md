# Testing feature branches with FluxCD

To test changes in a feature branch before merging to main:

1. Suspend flux-system to prevent it from reverting your changes
```sh
flux suspend ks flux-system
````

2. Switch to feature branch
```sh
kubectl edit gitrepository flux-system -n flux-system
```

3. Change GtRepostitory `spec.ref.branch` value to feature-branch name

4. Reconcile other kustomizations from the new branch
```sh
flux reconcile source git flux-system
flux reconcile ks ...
```

## Set the branch back to main
Once testing is successful, the feature branch should be merged and FluxCD should point back to the main branch:
1. Switch back to main and resume
```sh
kubectl edit gitrepository flux-system -n flux-system
```
2. Change spec.ref.branch back to main
```sh
flux reconcile source git flux-system
flux resume ks flux-system
```
