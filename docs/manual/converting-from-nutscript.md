# Information - Porting From NS

If you're considering porting Nutscript Plugins to Lilia Modules, here are some helpful pointers on replaceable variables. It's worth noting that while porting from Nutscript to Lilia is feasible and supported, going the other way around can be complex and may lead to long-term issues, as certain key functions used in Lilia are not present in Nutscript.

```

|  **Nutscript**  	|    **Lilia**    	|
|:---------------:	|:---------------:	|
|       nut       	|       lia       	|
|      PLUGIN     	|      MODULE     	|
|    sh_plugin    	|      module     	|
|    sh_schema    	|      schema     	|
| nut.plugin.list 	| lia.module.list 	|
|    sh_itemid    	|      itemid     	|
|   sh_factionid  	|    factionid    	|
|  sh_attributeid 	|     attribid    	|

```

Make sure to check the following available content to get assistance with your porting:

- [Class Structure](https://lilia-framework.github.io/Lilia/manual/class/)

- [Command Structure](https://lilia-framework.github.io/Lilia/manual/command/)

- [Faction Structure](https://lilia-framework.github.io/Lilia/manual/faction/)

- [Item Structure](https://lilia-framework.github.io/Lilia/manual/items)