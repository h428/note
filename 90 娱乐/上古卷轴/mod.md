
# 准备工作

- 推荐使用重置版，安装时选择英文版，同时运行一次游戏再进行后续的 mod 配置
- 常见的 mod 管理工具有 4 个，Vortex、NMM、MO、MO2，推荐 Vortex
- [参考教程](https://www.bilibili.com/video/BV1mC4y187KL)
- [参考教程2](https://www.bilibili.com/video/BV1R5411H7Nv)
- Mod Organizer2：将自己的 mods/XXX 文件夹虚拟成游戏的 Data 文件夹进行一一对应，因此 MO2 的文件结构为 mods\指定MOD目录\mod.esp
- mod 分为自动 mod 和手动 mod，手动 mod 要自己对上上述目录规则，自动 mod 内部一般有个 fomod，在 MO2 内部安装即可

# 替换型前置补丁

- [天际脚本扩展工具/Skrim Script Extender，SKSE](https://skse.silverlock.org/)，用于扩展老滚 5 的 mod 兼容性，例如要安装 SkyUI 则必须要安装该工具，SKSE 本质不是一个 mod 而是一个替代性的程序，下载解压后放到文件根目录即可，注意安装 SKSE 要和游戏版本对应，目前游戏版本为 1.5.97

- [mod 成就解锁补丁 Achievements Mods Enabler](https://www.nexusmods.com/skyrimspecialedition/mods/245)，下载并解压到游戏根目录即可

# 前置依赖

- mod 推荐顺序
```js
类别 00：非官方 Bug 修复和其他 Mod 的 ESM 文件
类别 01：界面前置
类别 02：生物添加
类别 03：NPC 添加分类
类别 04：武器装备
类别 05：魔法杂物
类别 06：天赋修改
类别 07：NPC 增强
类别 08：任务对话
类别 09：功能增强
类别 10：动作添加
类别 11：生物骨骼
类别 12：NPC 美化
类别 13：独立种族
类别 14：人物美化
类别 15：建筑添加
类别 16：房屋美化
类别 17：环境材质
类别 18：音效增强
类别 19：光影修改
类别 20：天气修改
```

# 类别 0：基础前置

- [0001 Unofficial Chinese Localisation for Skyrim By WOK Studios for SSE](https://www.nexusmods.com/skyrimspecialedition/mods/10845)：汤镬汉化 mod
- 此外还有 [Unofficial Chinese Translation for Skyrim Special Edition](https://www.nexusmods.com/skyrimspecialedition/mods/1333)：大学汉化 mod，个人习惯汤镬汉化
- [0002 Unofficial Skyrim Special Edition Patch](https://www.nexusmods.com/skyrimspecialedition/mods/266)：即常说的 USSEP，由 modder 制作的非官方补丁，用于修复官方没有修复的 Bug
    - 同时需要为该补丁安装汉化，[USSEP 汤镬汉化](https://www.nexusmods.com/skyrimspecialedition/mods/20940) 不属于完整 mod，为替换文件，直接替换 `002 Unofficial Skyrim Special Edition Patch` 目录下的对应文件即可完成汉化
    - 注意 `USSEP 汤镬汉化` 依赖 `001 Unofficial Chinese Localisation for Skyrim By WOK Studios for SSE`，注意依赖顺序
- [0003 USSEP Necromage fix](https://www.nexusmods.com/skyrimspecialedition/mods/3202)：USSEP 移除了恢复系 `亡灵 perk` 的增强，该 mod 为反修补，使得该 perk 对吸血鬼等亡灵生效
- [0004 Address Library for SKSE Plugins](https://www.nexusmods.com/skyrimspecialedition/mods/32444)：SKSE 插件地址库，注意下载后文件名是 All in one，最好将其改为和 mod 名字统一，目前更好的跳跃和展示敌人等级都依赖该 mod
- [0005 FNIS, Fores New Idles in Skyrim SE - FNIS SE](https://www.nexusmods.com/skyrimspecialedition/mods/3038)
- [0006 PapyrusUtil SE - Modders Scripting Utility Functions](https://www.nexusmods.com/skyrimspecialedition/mods/13048)：灵魂石多线程前置 mod
- [0007 JContainers SE](https://www.nexusmods.com/skyrimspecialedition/mods/16495)：通用前置，使用基于 JSON 的可序列化数据结构（如数组和地图）扩展 Skyrim SE Papyrus 脚本
- [0008 UI Extensions](https://www.nexusmods.com/skyrim/mods/57046)：UI 状态栏扩展，[汉化版](http://www.9damaogame.com/forum.php?mod=viewthread&tid=33878&extra=page%3D1%26filter%3Dtypeid%26typeid%3D71)
- [0009 Fuz Ro D'oh]()
- [0010 FileAccess Interface for Skyrim SE Scripts - FISSES](https://www.nexusmods.com/skyrimspecialedition/mods/13956)：FISSES

# 类别 1：动画前置

- 例如 SkyUI
- [1001 SkyUI](https://www.nexusmods.com/skyrimspecialedition/mods/12604)：理应算界面 mod，但由于很常用则归为通用 mod
- [1002 SkyUI v5.2 CHS](https://www.nexusmods.com/skyrimspecialedition/mods/45137)：Sky UI 汉化 mod，单独作为一个 mod
- [1003 XP32 Maximum Skeleton Extended - XPMSE](https://www.nexusmods.com/skyrimspecialedition/mods/1988)：XP32 最大兼容骨骼，SexLab 前置
- [1004 Caliente's Beautiful Bodies Enhancer -CBBE-](https://www.nexusmods.com/skyrimspecialedition/mods/198)
- [1005 BodySlide and Outfit Studio](https://www.nexusmods.com/skyrimspecialedition/mods/201)
- [1006 HDT-SMP (Skinned Mesh Physics)](https://www.nexusmods.com/skyrimspecialedition/mods/30872)：HDT-SMP 物理系统
- [1007 Faster HDT-SMP](https://www.nexusmods.com/skyrimspecialedition/mods/57339)：更快的 HDT SMP 物理系统
- [1008 Mfg Fix](https://www.nexusmods.com/skyrimspecialedition/mods/11669)
- [1009 CBPC](https://www.nexusmods.com/skyrimspecialedition/mods/21224)
- [1010 RaceMenu](https://www.nexusmods.com/skyrimspecialedition/mods/19080)：捏脸


# 类别 2：作弊 mod

- [2001 Carry Weight Modifier](https://www.nexusmods.com/skyrimspecialedition/mods/2176)：设置负重倍数
- [2002 Infinite Sprint - Omniguous](https://www.nexusmods.com/skyrimspecialedition/mods/46802)：无限冲刺，无冲刺消耗
- [2003 Rich Skyrim Merchants](https://www.nexusmods.com/skyrimspecialedition/mods/1772)：更富裕的商人
- [2004 Skyrim Unlimited Training](https://www.nexusmods.com/skyrimspecialedition/mods/774)：无限训练
- [2005 Unlimited Magicka](https://www.nexusmods.com/skyrimspecialedition/mods/38321)：无法力消耗
- [2006 Stamina and Magicka Regen](https://www.nexusmods.com/skyrimspecialedition/mods/22626)：魔法和耐力快速生
- [2007 Enhanced Belethor's shop](https://www.nexusmods.com/skyrimspecialedition/mods/4912)：增强型白漫城杂货店，可以买很多稀有东西
- [2008 Perk Point Book](https://www.nexusmods.com/skyrimspecialedition/mods/2254)：阅读一次获得 1 技能点
- [2009 Easy Lockpicking](https://www.nexusmods.com/skyrimspecialedition/mods/4070)：开锁更容易
- [2010 Store Bodies in Scrolls](https://www.nexusmods.com/skyrimspecialedition/mods/15463)：使用卷轴保存尸体，卷轴找商人购买或者使用控制台
- [2012 No Player Fall Damage](https://www.nexusmods.com/skyrimspecialedition/mods/5210)：无掉落伤害
成
- [2011 Unlimited Summons](https://www.nexusmods.com/skyrimspecialedition/mods/1554)：修改 `Twin Souls` 使得拥有 1000 个召唤物而不只是两个




# 类别 3：任务对话


- [3001 The Paarthurnax Dilemma](https://www.nexusmods.com/skyrimspecialedition/mods/365)：允许叱责俩傻逼刀锋，从而不用杀死帕图纳克斯而继续做刀锋任务，[汉化文件](https://www.nexusmods.com/skyrimspecialedition/mods/21002)
- [3002 巴兰兹雅之石任务标记](https://www.nexusmods.com/skyrimspecialedition/mods/684)
- [3003 Legacy of the Dragonborn SSE](https://www.nexusmods.com/skyrimspecialedition/mods/11802)：龙裔艺术馆，以及对应[汉化](https://www.nexusmods.com/skyrimspecialedition/mods/57591)
- [3004 Beyond Skyrim - Bruma SE](https://www.nexusmods.com/skyrimspecialedition/mods/10917)：超越天际，对应 [汉化](https://www.nexusmods.com/skyrimspecialedition/mods/33079)
- [3005 Helgen Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/5673)：海尔根重生，对应[汉化](https://www.nexusmods.com/skyrimspecialedition/mods/21001)
- [3006 VIGILANT SE](https://www.nexusmods.com/skyrimspecialedition/mods/11849)：斯丹达尔警戒者任务，对应[汉化](https://www.nexusmods.com/skyrimspecialedition/mods/33110)，[语音](https://www.nexusmods.com/skyrimspecialedition/mods/11894)
- [3007 The Forgotten City](https://www.nexusmods.com/skyrimspecialedition/mods/1179)：被遗忘的城市，重置版无汉化


# 类别 4：功能增强

- [4001 A Quality World Map](https://www.nexusmods.com/skyrimspecialedition/mods/5804)：高清地图 
- [4002 A Matter of Time - A HUD clock widget](https://www.nexusmods.com/skyrimspecialedition/mods/12937)：显示时间，前置 mod 为 `003 SkyUI`
- [4003 Display Enemy Level](https://www.nexusmods.com/skyrimspecialedition/mods/18533)：展示敌人等级和血量，前置依赖为 `101 Address Library for SKSE Plugins`
- [4004 Unread Books Glow SSE](https://www.nexusmods.com/skyrimspecialedition/mods/1296)：未读书籍发光

- [4005 Better Dialogue Controls](https://www.nexusmods.com/skyrim/mods/27371)：对话鼠标修正
- [4006 Better Jumping SE](https://www.nexusmods.com/skyrimspecialedition/mods/18967)：奔跑中可以跳跃，同时可配置跳跃高度、重复跳跃
- [4007 Disable Follower Collision](https://www.nexusmods.com/skyrimspecialedition/mods/35925)：取消随从碰撞体积 ，控制台输入 tfcl 进行开关
- [4008 Protect your People](https://www.nexusmods.com/skyrimspecialedition/mods/10297)：随从以及 NPC 不会被他人杀死
- [4009 Acquisitive Soul Gems Multithreaded](https://www.nexusmods.com/skyrimspecialedition/mods/1469)：灵魂石多线程，注意有汉化包
- [4010 Alternate Start - Live Another Life - SSE](https://www.nexusmods.com/skyrimspecialedition/mods/272)：不一样的人生
- [4010 Alternate Start - Live Another Life - SSE](https://www.nexusmods.com/skyrimspecialedition/mods/272)：不一样的人生汉化
- [4011 Breezehom](https://www.nexusmods.com/skyrimspecialedition/mods/2829)：微风阁 mod，[汉化版](http://www.9damaogame.com/forum.php?mod=viewthread&tid=10908&highlight=Breezehome)
- [4012 Copy and Paste in Console](https://www.nexusmods.com/skyrimspecialedition/mods/30928)：控制台可粘贴
- [4013 Fast Travel When Indoors](https://www.nexusmods.com/skyrimspecialedition/mods/26536)：室内快速旅行，[汉化版](http://www.9damaogame.com/forum.php?mod=viewthread&tid=186874&highlight=%BF%EC%CB%D9%C2%C3%D0%D0)
- [4014 Floating Damage](https://www.nexusmods.com/skyrimspecialedition/mods/14332)：伤害显示
- [4015 Quick Loot RE](https://www.nexusmods.com/skyrimspecialedition/mods/21085)：快速拾取
- [4016 More Informative Console](https://www.nexusmods.com/skyrimspecialedition/mods/19250)：选择对象后，展示详细的控制台信息，可按 tab 修改模式
- [4017 Amazing Follower Tweaks SE]()：随从管理


# 类别 5：机制修改

- [5001 Ordinator - Perks of Skyrim](https://www.nexusmods.com/skyrimspecialedition/mods/1137)：技能树大修，对应[中文汉化](https://www.nexusmods.com/skyrimspecialedition/mods/57464)
- [5002 Apocalypse - Magic of Skyrim](https://www.nexusmods.com/skyrimspecialedition/mods/1090)：魔法大修，对应的[中文汉化](https://www.nexusmods.com/skyrimspecialedition/mods/7934)
- [5003 Immersive Patrols SE](https://www.nexusmods.com/skyrimspecialedition/mods/718)：沉浸式巡逻，对应[汉化](https://www.nexusmods.com/skyrimspecialedition/mods/59047)


# 类别 6：环境材质

- [6001 Skyrim 3D Trees and Plants](https://www.nexusmods.com/skyrimspecialedition/mods/12371)：3D 树木和植物，该 mod 有 [汤镬名词汉化](https://www.nexusmods.com/skyrimspecialedition/mods/40019)，下载后直接替换原 mod 同名文件即可
- [6002 Static Mesh Improvement Mod - SMIM](https://www.nexusmods.com/skyrimspecialedition/mods/659)：更好的静态纹理，[汉化版](http://www.9damaogame.com/forum.php?mod=viewthread&tid=153905&highlight=Static%2BMesh)
- [6003 Realistic Water Two SE](https://www.nexusmods.com/skyrimspecialedition/mods/2182)：水优化，[汉化文件](https://www.nexusmods.com/skyrimspecialedition/mods/61902)
- [6004 Enhanced Blood Textures](https://www.nexusmods.com/skyrimspecialedition/mods/2357)：血液纹理增强
- [6005 Immersive College of Winterhold SE](https://www.nexusmods.com/skyrimspecialedition/mods/17004)：沉浸式冬堡学院，需自己手动汉化
- [6006 Skyrim Immersive Creatures Special Edition](https://www.nexusmods.com/skyrimspecialedition/mods/12680)：沉浸式生物


# 类别 7：实验室

- 注意通用前置：SKSE, SkyUI(003), XPMSSE(151), JContainers SE(202)
- [7001 SexLab](https://www.loverslab.com/topic/91861-sexlab-framework-se-163-beta-9-august-5th-2021/)：实验室
- [7002 Creature Framework SE 1.0.1](https://www.loverslab.com/files/file/5462-creature-framework-se/)：允许其他模组轻松提供身体替换和与 SexLab 和 SexLab Aroused 的集成，[汉化版](http://www.9damaogame.com/thread-112633-1-1.html)
- [7003 SexLab Animation Loader SSE 1.0.0](https://www.loverslab.com/files/file/5328-sexlab-animation-loader-sse/)：动画加载器，[汉化版](http://www.9damaogame.com/forum.php?mod=viewthread&tid=92140&highlight=SexLab%2BAnimation%2BLoader)
- [7004 Sexlab tools for SE](https://www.loverslab.com/files/file/10660-sexlab-tools-for-se-patched/)：Sexlab 工具，允许按 H 选择不同姿势，[汉化版](http://www.9damaogame.com/thread-33879-1-1.html)
- [7005 Dynamic Animation Replacer](https://www.nexusmods.com/skyrimspecialedition/mods/33746)：`7401 Sexlab Defeat Baka Edition` 建议前置
- [7006 Fuz Ro D-oh - Silent Voice](https://www.nexusmods.com/skyrimspecialedition/mods/15109)：`7401 Sexlab Defeat Baka Edition` 所需前置
- [7007 Furniture Sex Framework 0.14.3](https://www.loverslab.com/files/file/13464-furniture-sex-framework/)：支持家具动画所需前置
- [7008 More Nasty Critters Special Edition 12.6](https://www.loverslab.com/files/file/5464-more-nasty-critters-special-edition/)：要求前置 Jcontainers(202), Creatureframework(702)，有两个子 mod，用于生物 sex 的支持


- [7101 Funnybizness SLAL Packs SE 1.0.0](https://www.loverslab.com/files/file/5716-funnybizness-slal-packs-se/)：Funnybizness 的动画资源
- [7102 ZAZ Animation Packs for SE 1.0.0](https://www.loverslab.com/files/file/5957-zaz-animation-packs-for-se/)：[汉化版](http://www.9damaogame.com/thread-227660-1-1.html)
- [7103 Anubs Animations for SE](https://www.loverslab.com/files/file/5623-anubs-animations-for-se/)：Anub 动画
- [7104 Milky animations for SE](https://www.loverslab.com/files/file/6019-milkyslal-for-se/)：Milky 动画
- [7105 Billyy Animations](https://www.loverslab.com/files/file/3999-billyys-slal-animations-2022-4-2/)：Billyy 动画
- [7110 7007 家具动画替换](https://www.loverslab.com/files/file/13464-furniture-sex-framework/)


- [7301 Schlongs of Skyrim SE 1.1.4](https://www.loverslab.com/files/file/5355-schlongs-of-skyrim-se/)：天际巨根，[汉化版](http://www.9damaogame.com/forum.php?mod=viewthread&tid=186097&highlight=%CC%EC%BC%CA%BE%DE%B8%F9)
- [7301 Schlongs Of Skyrim Light SE 1.4](https://www.loverslab.com/files/file/3705-schlongs-of-skyrim-light-se/)：天际巨根 light 版
- [7303 Animated Beast's Cocks](https://www.loverslab.com/files/file/7556-animated-beasts-cocksabc-for-users-le-se/)：动物巨根，用于支持生物 sex
- [7304 Sexlab Aroused Redux SSE Version 29 2.9](https://www.loverslab.com/files/file/5482-sexlab-aroused-redux-sse-version-29/)：性唤起、情欲，SOS 支持，[汉化版](http://www.9damaogame.com/thread-141840-1-1.html)
- [7304 Sexlab Aroused Redux SE BakaFactory Edited Version](https://drive.google.com/file/d/1SlvS2KRY6UscQisro8GEskwCCKg4Wa3G/view)：SLA 另一版本

- [7401 Sexlab Defeat SSE 5.3.5](https://www.loverslab.com/files/file/9152-sexlab-defeat-sse/)：战败惩罚，[汉化版](http://www.9damaogame.com/thread-230230-1-1.html)
- [7401 Sexlab Defeat Baka Edition](https://www.loverslab.com/files/file/18689-sexlab-defeat-baka-edition-lese/)：[汉化文件](http://www.9damaogame.com/thread-225092-1-1.html)
- [7402 Sexlab Eager NPC](https://www.loverslab.com/files/file/7309-sexlab-eager-npcs-se-slen/)：NPC 性欲，可对话啪啪啪
- [7403 Naked Defeat SE](https://www.loverslab.com/files/file/17888-naked-defeat-se/)




