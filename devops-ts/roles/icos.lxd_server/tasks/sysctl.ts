import { loopOver, type TaskFile, type Tmpl } from "../../../lib/ansible.ts";

export default [
  // https://linuxcontainers.org/lxd/docs/master/production-setup/
  loopOver<{ name: Tmpl; value: number }>(
    [
      // "Maximum number of concurrent asynchronous I/O operations (you might need
      // to increase this limit further if you have a lot of workloads that use
      // the AIO subsystem, for example, MySQL)"
      { name: "fs.aio-max-nr", value: 524288 },

      // "This specifies an upper limit on the number of events, instances and
      // watches that can be created per real user ID."
      { name: "fs.inotify.max_queued_events", value: 1048576 },
      { name: "fs.inotify.max_user_instances", value: 1048576 },
      { name: "fs.inotify.max_user_watches", value: 1048576 },

      // Turns out that maxkeys isn't enough, one need to bump maxbytes as well.
      { name: "kernel.keys.maxbytes", value: 100000 },

      // "This is the maximum number of keys a non-root user can use, should be
      // higher than the number of containers"
      { name: "kernel.keys.maxkeys", value: 4000 },

      // "This is the maximum number of entries in ARP table. You should increase
      // this if you create over 1024 containers"
      { name: "net.ipv4.neigh.default.gc_thresh3", value: 8192 },
      { name: "net.ipv6.neigh.default.gc_thresh3", value: 8192 },

      // "This file contains the maximum number of memory map areas a process may
      // have."
      { name: "vm.max_map_count", value: 262144 },

      // "This denies container access to the messages in the kernel ring buffer."
      { name: "kernel.dmesg_restrict", value: 1 },

      // https://wiki.mikejung.biz/Sysctl_tweaks#net.core.netdev_max_backlog
      { name: "net.core.netdev_max_backlog", value: 300000 },
    ],
    (item) => ({
      name: "Set sysctl value",
      sysctl: {
        name: item.name,
        value: item.value,
      },
    }),
  ),
] satisfies TaskFile;
