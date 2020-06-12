# selenium


## 1 元素查找

#### By ID

    <div id="coolestWidgetEvah">...</div>
    实现

    element = driver.find_element_by_id("coolestWidgetEvah")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    element = driver.find_element(by=By.ID, value="coolestWidgetEvah")

#### By Class Name

    <div class="cheese"><span>Cheddar</span></div><div class="cheese"><span>Gouda</span></div>
    实现

    cheeses = driver.find_elements_by_class_name("cheese")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    cheeses = driver.find_elements(By.CLASS_NAME, "cheese")

#### By Tag Name

    <iframe src="..."></iframe>
    实现

    frame = driver.find_element_by_tag_name("iframe")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    frame = driver.find_element(By.TAG_NAME, "iframe")

#### By Name

    <input name="cheese" type="text"/>
    实现

    cheese = driver.find_element_by_name("cheese")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    cheese = driver.find_element(By.NAME, "cheese")

#### By Link Text

    <a href="http://www.google.com/search?q=cheese">cheese</a>
    实现

    cheese = driver.find_element_by_link_text("cheese")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    cheese = driver.find_element(By.LINK_TEXT, "cheese")

#### By Partial Link Text

    <a href="http://www.google.com/search?q=cheese">search for cheese</a>>
    实现

    cheese = driver.find_element_by_partial_link_text("cheese")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    cheese = driver.find_element(By.PARTIAL_LINK_TEXT, "cheese")

#### By CSS

    <div id="food"><span class="dairy">milk</span><span class="dairy aged">cheese</span></div>
    实现

    cheese = driver.find_element_by_css_selector("#food span.dairy.aged")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    cheese = driver.find_element(By.CSS_SELECTOR, "#food span.dairy.aged")

#### By XPath

    <input type="text" name="example" />
    <INPUT type="text" name="other" />
    实现

    inputs = driver.find_elements_by_xpath("//input")
    ------------------------ or -------------------------
    from selenium.webdriver.common.by import By
    inputs = driver.find_elements(By.XPATH, "//input")


## 2 鼠标动作链

有些时候，我们需要再页面上模拟一些鼠标操作，比如双击、右击、拖拽甚至按住不动等，我们可以通过导入 ActionChains 类来做到：

    #导入 ActionChains 类
    from selenium.webdriver import ActionChains

    # 鼠标移动到 ac 位置
    ac = driver.find_element_by_xpath('element')
    ActionChains(driver).move_to_element(ac).perform()


    # 在 ac 位置单击
    ac = driver.find_element_by_xpath("elementA")
    ActionChains(driver).move_to_element(ac).click(ac).perform()

    # 在 ac 位置双击
    ac = driver.find_element_by_xpath("elementB")
    ActionChains(driver).move_to_element(ac).double_click(ac).perform()

    # 在 ac 位置右击
    ac = driver.find_element_by_xpath("elementC")
    ActionChains(driver).move_to_element(ac).context_click(ac).perform()

    # 在 ac 位置左键单击hold住
    ac = driver.find_element_by_xpath('elementF')
    ActionChains(driver).move_to_element(ac).click_and_hold(ac).perform()

    # 将 ac1 拖拽到 ac2 位置
    ac1 = driver.find_element_by_xpath('elementD')
    ac2 = driver.find_element_by_xpath('elementE')
    ActionChains(driver).drag_and_drop(ac1, ac2).perform()

## 3 填充表单

我们已经知道了怎样向文本框中输入文字，但是有时候我们会碰到 `<select> </select>` 标签的下拉框。直接点击下拉框中的选项不一定可行。

    <select id="status" class="form-control valid" onchange="" name="status">
        <option value=""></option>
        <option value="0">未审核</option>
        <option value="1">初审通过</option>
        <option value="2">复审通过</option>
        <option value="3">审核不通过</option>
    </select>


Selenium专门提供了Select类来处理下拉框。 其实 WebDriver 中提供了一个叫 Select 的方法，可以帮助我们完成这些事情：

    # 导入 Select 类
    from selenium.webdriver.support.ui import Select

    # 找到 name 的选项卡
    select = Select(driver.find_element_by_name('status'))

    #
    select.select_by_index(1)
    select.select_by_value("0")
    select.select_by_visible_text(u"未审核")

以上是三种选择下拉框的方式，它可以根据索引来选择，可以根据值来选择，可以根据文字来选择。注意：

    index 索引从 0 开始
    value是option标签的一个属性值，并不是显示在下拉框中的值
    visible_text是在option标签文本的值，是显示在下拉框的值
    全部取消选择怎么办呢？很简单:

    select.deselect_all()

## 4 弹窗处理

当你触发了某个事件之后，页面出现了弹窗提示，处理这个提示或者获取提示信息方法如下：

    alert = driver.switch_to_alert()

## 5 页面切换

一个浏览器肯定会有很多窗口，所以我们肯定要有方法来实现窗口的切换。切换窗口的方法如下：

    driver.switch_to.window("this is window name")

也可以使用 window_handles 方法来获取每个窗口的操作对象。例如：

    for handle in driver.window_handles:
        driver.switch_to_window(handle)

## 6 页面前进和后退

操作页面的前进和后退功能：

    driver.forward()     #前进
    driver.back()        # 后退

## 7 Cookies
获取页面每个Cookies值，用法如下

    for cookie in driver.get_cookies():
      print "%s -> %s" % (cookie['name'], cookie['value'])

删除Cookies，用法如下

    # By name
    driver.delete_cookie("CookieName")

    # all
    driver.delete_all_cookies()

## 8 页面等待

注意：这是非常重要的一部分！！

现在的网页越来越多采用了 Ajax 技术，这样程序便不能确定何时某个元素完全加载出来了。如果实际页面等待时间过长导致某个dom元素还没出来，但是你的代码直接使用了这个WebElement，那么就会抛出NullPointer的异常。

为了避免这种元素定位困难而且会提高产生 ElementNotVisibleException 的概率。所以 Selenium 提供了两种等待方式，一种是隐式等待，一种是显式等待。

隐式等待是等待特定的时间，显式等待是指定某一条件直到这个条件成立时继续执行。

#### 显式等待

显式等待指定某个条件，然后设置最长等待时间。如果在这个时间还没有找到元素，那么便会抛出异常了。

    from selenium import webdriver
    from selenium.webdriver.common.by import By
    # WebDriverWait 库，负责循环等待
    from selenium.webdriver.support.ui import WebDriverWait
    # expected_conditions 类，负责条件出发
    from selenium.webdriver.support import expected_conditions as EC

    driver = webdriver.Chrome()
    driver.get("http://www.xxxxx.com/loading")
    try:
        # 页面一直循环，直到 id="myDynamicElement" 出现
        element = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "myDynamicElement"))
        )
    finally:
        driver.quit()

如果不写参数，程序默认会 0.5s 调用一次来查看元素是否已经生成，如果本来元素就是存在的，那么会立即返回。

下面是一些内置的等待条件，你可以直接调用这些条件，而不用自己写某些等待条件了。

    title_is
    title_contains
    presence_of_element_located
    visibility_of_element_located
    visibility_of
    presence_of_all_elements_located
    text_to_be_present_in_element
    text_to_be_present_in_element_value
    frame_to_be_available_and_switch_to_it
    invisibility_of_element_located
    element_to_be_clickable – it is Displayed and Enabled.
    staleness_of
    element_to_be_selected
    element_located_to_be_selected
    element_selection_state_to_be
    element_located_selection_state_to_be
    alert_is_present

#### 隐式等待

隐式等待比较简单，就是简单地设置一个等待时间，单位为秒。

    from selenium import webdriver

    driver = webdriver.Chrome()
    driver.implicitly_wait(10) # seconds
    driver.get("http://www.xxxxx.com/loading")
    myDynamicElement = driver.find_element_by_id("myDynamicElement")
    当然如果不设置，默认等待时间为0。
