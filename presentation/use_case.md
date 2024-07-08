
# Use Case Presentation

by

Riccardo Scartozzi

Note: This is a 5 minutes presentation of the PoC. More details will be in the relevant code/folder/readme.

----

# PoC architecture details

--

# Constrains

The following is requested:

![elements](images/elements.svg "elements")

--

# Implementation

![implementation](images/poc.svg "impl")

----

# Setup

For this PoC:

* deploy on Virtual Machine: isolate kernel and networking, portable to other system
* image setup as nixos deviation
* k3s

  * local filesystem as storage CSI
  * k3s plain network setup (flannel, traeffik and serviceLB)

--

For more details: see [github](https://github.com/Sjd-Risca/use_case)

----

# k8s resources


```
   kubectl get all -n poc
```

As defined by [github/poc/k8s](https://github.com/Sjd-Risca/use_case/tree/master/poc/k8s).


----

Network flow
============


----

Going to Prod
=============

Hardening for production

--

HA design
=========

![AWS](images/AWS.eks.svg "AWS eks")

--

More SAAS
=========

![AWS Saas](images/AWS.saas.svg "AWS saas")

----

More production consideration
=============================

* Load balancing (classic, application, network)
* DNS routing (geoproxymity, failover)
* High availability (multiAZ, multiRegion and costs)
* Horizontal and vertical auto-scaling (pod scaling, node scaling)
* Update and backup strategy:

  * CICD: argoCD, dagger.io
  * backups: incremental, snapshots...
