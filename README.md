# VCC 2024 Exam Template

## Using this project

### Virtual machines

We advise you to use this project via Vagrant (`vagrant up` to start the VMs, VMWare required).

From the `VCC-controlnode` node then you can point at the two workers `target1` and `target2`.

Of course, any way of creating two Ubuntu 24.04 machines and launching on them an Ansible playbook is fine.

If you don't have VMWare, possible alternatives are VirtualBox and libvirt.

### What has been done for you already

This project comes with plenty of pre-made stuff.
You just need to use it!

#### Local registry

This playbook will automatically provision a local registry, listening over port 5000 via HTTP.
Such registry uses NFS for its backing storage.
All nodes can reach it at `registry.vcc.internal:5000`.

#### Image building

The `swarm-images` role will automatically build and push any image found under its `files/images` directories to the [Local registry](#local-registry).

So, for instance, `files/images/forgejo` will be built and pushed as `registry.vcc.internal:5000/forgejo:latest`.

#### Image refreshing

For your own convenience, the role `pull-images` will automatically force each swarm node to re-pull locally hosted images from the local registry, ensuring their freshness.

#### Swarm services deployment

The role `swarm-services` is a good workhorse for your experimentation.

It will:

- Automatically copy all files listed in the variable `stack_file_names` from its `templates` directory to the remote host
  - We advise you to use the default value and doing everything inside of `exam.yml`
- Destroy the `vcc` docker stack
- Delete the directories under `/data` whose name is in the `stack_data_directories` variable
- Create under `/data` directories with names found in the `stack_data_directories` variable
- Copy everything found in `files/configs` to `/data/configs`
- Deploy the stack

Combining this with previous roles means that you have a powerful way to iterate on your stack files, with each run recreating the whole environment.

Please see also [the makefile targets which are available](#available-makefile-targets).

### Available makefile targets

From the root of the project run

- `make setup-all` to run all roles in playbook.yml
- `make setup-from-images-onwards` to rebuild images and redeploy all services
- `make setup-from-service-onwards` to redeploy all services
- `make python-setup` will prepare an Ansible installation with the collections indicated in `requirements.yml`

Please ensure that you have an Ansible inventory called `inventory` or set the `INVENTORY` variable in the makefile.

## Support contact

Giacomo Longo <giacomo.longo@dibris.unige.it>
