#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/kallsyms.h>

#include "br_private.h"

struct jprobe jp;

int jp_br_stp_recalculate_bridge_id(struct net_bridge *br)
{
  printk(KERN_INFO "*%s: flags:(%ld)\n", br->dev->name, br->flags);

  jprobe_return();
  return 0;
}

static __init int init_bridge_ifinfo_dumper(void)
{
  jp.kp.symbol_name = "br_stp_recalculate_bridge_id";
  jp.entry = JPROBE_ENTRY(jp_br_stp_recalculate_bridge_id);
  register_jprobe(&jp);
  return 0;
}
module_init(init_bridge_ifinfo_dumper);

static __exit void cleanup_bridge_ifinfo_dumper(void)
{
  unregister_jprobe(&jp);
}
module_exit(cleanup_bridge_ifinfo_dumper);

MODULE_LICENSE("GPL");
