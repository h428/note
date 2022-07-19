


# 生命周期和插件

- Maven 对所有的构建过程进行抽象和统一，构建了一套高度完善的、易扩展的生命周期，其包含了项目的清理、初始化、编译、测试、打包、集成测试、验证、部署和站点生成等
- Maven 定义的生命周期是抽象的，意味着生命周期本身不做任何实际工作，实际的工作（例如编译源代码）都交由某一插件来完成，当某插件绑定到 Maven 的某一生命周期后，该生命周期的工作则交由该插件完成

## 生命周期

- Maven 提供了三套互相独立的生命周期，分别为 clean、default 和 site，clean 生命周期的目的是清理项目，default 生命周期的目的是构建项目，而 site 生命周期的目的是建立站点项目
- 每个生命周期包含一些阶段（phase），这些阶段是有顺序的，且后面的阶段依赖前面的阶段，和 Maven 最直接的交互方式就是直接调用这些生命周期阶段
- clean 生命周期包含三个阶段：pre-clean、clean 和 post-clean，当用户调用 clean 时，会执行 pre-clean 和 clean 两个阶段
- 生命周期的各个阶段是存在依赖关系的，但三套声明周期是互相独立的，例如调用 default 生命周期的 compile 阶段并不影响 clean 生命周期，也就是不会触发清理工作，因此才有一般的 `mvn clean compile` 编译命令
- default 生命周期定义了构建所需要的所有步骤，是生命周期的核心部分，其包含大量阶段，我们常用的 compile, test-compile, test, package, verify, install, deploy 都是属于该生命周期的
- default 声明周期的所有阶段：validate, initialize, generate-sources, process-sources, generate-resources, process-resources, compile, process-classes, generate-test-sources, process-test-sources, generate-test-resources, process-test-resources, test-compile, process-test-classes, test, prepare-package, package, pre-integration-test, integration-test, post-integration-test, verify, install, deploy
- site 生命周期用于建立和发布站点，Maven 能基于 pom 包含的信息自动生成一个友好的站点，方便团队交流和发布项目信息，其包含 pre-site, site, post-site, site-deploy 阶段


## 命令行

- 从命令行执行 Maven 任务的最主要方式就是调用 Maven 生命周期阶段，执行命令行时需要注意的时各个生命周期是互相独立的，而一个生命周期的阶段是有前后依赖关系的
- `mvn clean`：该命令调用 clean 声明周期的 clean 阶段，因此会实际执行 clean 生命周期的 pre=clean, clean 阶段
- `mvn test`：调用 default 生命周期的 test 阶段，会实际执行 default 声明周期的 validate 到 test 的所有阶段，这也解释了为什么
- `mvn clean install`：调用 clean 生命周期的 clean 阶段和 default 生命周期的 install 阶段，会实际执行 clean 生命周期的 pre-clean、clean 阶段以及 default 的 validate 到 install 的所有阶段，该命令结合了两个生命周期，先进行清理，再进行安装


## 插件

- 插件目标：对于一个插件，为了复用代码其往往能完成多个任务，例如 maven-dependency-plugin 能够基于项目依赖做很多事情，包括列出项目依赖树、分析依赖来源等，这些相近功能出于复用代码的需求而位于同一个插件中，因而一个插件可以包含多个功能，每个功能就是一个插件目标
- 例如 maven-dependency-plugin 有十多个目标，每个目标赌赢一个功能，例如 dependency:analyze, dependency:tree, dependency:list 等，冒号前面就是插件前缀，后面为插件目标，类似的还有 compiler:compile（maven-compile-plugin 的 compile 目标）
- 因此，我们实际上是将生命周期的阶段和插件目标进行绑定，例如编译任务，我们会将 maven-compiler-plugin 插件的 compile 目标绑定到 default 生命周期的 compile 阶段，之后我们执行 `mvn compile` 调用 default 生命周期的 compile 阶段，从而调用绑定的 maven-compiler-plugin:compile 目标进行编译工作
- 为了当用户不配置就能构建 Maven 项目，Maven 在主要的生命周期绑定了很多插件目标，当用户通过命令行调用生命周期阶段的时候，对应的插件目标就会被执行
- clean 生命周期的 clean 阶段默认与 maven-clean-plugin:clean 目标绑定，site 生命周期的 site 阶段和 site-deploy 阶段分别默认与 maven-site-plugin:site 和 maven-site-plugin:deploy 绑定
- default 生命周期各个阶段和插件目标的默认绑定关系如下表所示：

|阶段|插件目标|作用
|:---:|:---:|:---:|
|process-resources|maven-resources-plugin:resources|拷贝资源目录|
|compile|maven-compiler-plugin:compile|编译主代码|
|process-test-resources|maven-resources-plugin:testResources|拷贝测试资源目录|
|test-compile|maven-compiler-plugin:testCompile|编译测试代码|
|test|maven-surefire-plugin:test|执行测试用例|
|package|maven-jar-plugin:jar|构建项目 jar 包|
|install|maven-install-plugin:install|安装到本地仓库|
|deploy|maven-deploy-plugin:deploy|发布到远程仓库|
