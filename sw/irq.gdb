define irq
	dump_irq_sic_imask
	dump_irq_sic_ipend
	dump_irq_sic_ilat
	dump_irq_sic_miss

	dump_scache_cachestatus
	dump_scache_cachecontrol
	dump_scache_icachemask
	dump_scache_icachepagemask
	dump_scache_icacheoffset
	dump_scache_icachehitaddr
	dump_scache_dcachehitaddr
end

define irqoff
	set *$Reg_IRQ_SIC_IMASK = 0
end
