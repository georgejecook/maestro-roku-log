' RALE_Config - RALE config singleton class
' @return {object} - RALE config properties
Function RALE_Config() as Object
    if m.appConfig = Invalid then m.appConfig = RALE_InitConfig()
    return m.appConfig
End Function

' RALE_InitConfig - RALE config init function. Defines all config properties
' @return {object} - RALE config properties
Function RALE_InitConfig() as Object
    this = {
        bufferSize: 100024,
        minSocketPort: 49152,
        maxSocketPort: 65535,
        screensaverResetTimeout: 30000,
        commandTimeout: 10000,
        defaultLogLevel: 3,
        logFormat: "[RALE][%level%] - %message%"
    }

    return this
End Function


' RALE_Logger - Constructor of Logger class
' @param {integer} level - log verbosity level (0-4)
' @param {string} format - log message format ("[MY_CUSTOM_PREFIX]%message%")
' @return {object} - logger instance
function RALE_Logger(level = -1 as Integer, format = "%message%" as String) as Object
    this = {}

    this.verbosityList = ["OFF", "ERROR", "WARN", "INFO", "DEBUG"]
    this.verbosityMap = {
        off     : 0
        error   : 1
        warning : 2
        info    : 3
        debug   : 4
    }
    this.formatMethods = {
        date:    "getDate",
        time:    "getTime",
        level:   "getLevel",
        message: "getMessage"
    }

    this.dt = createObject("roDateTime")

    this.setVerbosity = RALE_Logger__SetVerbosityLevel
    this.setFormat    = RALE_Logger__SetFormat

    this.getDate    = RALE_Logger__GetDate
    this.getTime    = RALE_Logger__GetTime
    this.getLevel   = RALE_Logger__GetLevel
    this.getMessage = RALE_Logger__GetMessage

    this.debug      = RALE_Logger__DebugLog
    this.info       = RALE_Logger__InfoLog
    this.warning    = RALE_Logger__WarningLog
    this.error      = RALE_Logger__ErrorLog
    this.logMessage = RALE_Logger__LogMessage

    this.setVerbosity(level)
    this.setFormat(format)

    return this
end function

' RALE_Logger__SetVerbosityLevel - change logger verbosity level
' @param {integer} level - log verbosity level (0-4)
sub RALE_Logger__SetVerbosityLevel(level = 4 as Integer)
    if level > m.verbosityMap.debug then
        m.verbosityLevel = m.verbosityMap.debug
    else if level < m.verbosityMap.off then
        m.verbosityLevel = m.verbosityMap.off
    else
        m.verbosityLevel = level
    end if
end sub

' RALE_Logger__SetFormat - Change logger message format
' @param {string} format - log message format ("[MY_CUSTOM_PREFIX]%message%")
' Available format variables:
' %message% - message with which the log function is called (at the end by default)
' %date% - current date in format "[year]-[month]-[day]"
' %time% -  current time in format "[hours]:[minutes]:[seconds].[miliseconds]"
' %level% - verbosity level ("ERROR", "WARN", "INFO" or "DEBUG")
sub RALE_Logger__SetFormat(format = "%message%" as String)
    if Instr(1, format, "%message%") = 0 then
        format = format + "%message%"
    end if
    m.formatList = format.split("%")
end sub

'==========================================
' Wrappers over various levels of logging
'==========================================

' RALE_Logger__DebugLog - Log message into console with DEBUG verbosity level
' @param {string} message - log message
sub RALE_Logger__DebugLog(message = "")
    m.logMessage(message, m.verbosityMap.debug)
end sub

' RALE_Logger__InfoLog - Log message into console with INFO verbosity level
' @param {string} message - log message
sub RALE_Logger__InfoLog(message = "")
    m.logMessage(message, m.verbosityMap.info)
end sub

' RALE_Logger__WarningLog - Log message into console with WARNING verbosity level
' @param {string} message - log message
sub RALE_Logger__WarningLog(message = "")
    m.logMessage(message, m.verbosityMap.warning)
end sub

' RALE_Logger__ErrorLog - Log message into console with ERROR verbosity level
' @param {string} message - log message
sub RALE_Logger__ErrorLog(message)
    m.logMessage(message, m.verbosityMap.error)
end sub

'==========================================
' Main log function
'==========================================

' RALE_Logger__LogMessage - Log message into console by message format if logLevel is more than current verbosityLevel
' @param {string} message - log message
' @param {integer} logLevel - log verbosity level (0-4)
sub RALE_Logger__LogMessage(message as String, logLevel as Integer)
    if  logLevel > 0 and m.verbosityLevel >= logLevel then
        logMessage = ""

        for each item in m.formatList
            formatMethod = m.formatMethods[item]

            if formatMethod = Invalid then
                logMessage = logMessage + item
            else
                logMessage = logMessage + m[formatMethod](message, logLevel)
            end If
        end for

        print logMessage
    end if
end sub

'==========================================
' Utitlity functions
'==========================================

' RALE_Logger__GetTime - Returns current time
' @param {string} message - log message
' @return {string} - current time in format: "[hours]:[minutes]:[seconds].[miliseconds]"
function RALE_Logger__GetTime(message as String, level as Integer)
    m.dt.Mark()

    h = RALE_Logger__getZeroNumber(m.dt.getHours())
    n = RALE_Logger__getZeroNumber(m.dt.getMinutes())
    s = RALE_Logger__getZeroNumber(m.dt.getSeconds())
    ms = str(m.dt.getMilliseconds()).trim()
    if len(ms) = 1
      ms = ms + "0"
    else
      ms = left(ms, 2)
    end if
    return h + ":" + n + ":" + s + "." + ms
end function

' RALE_Logger__GetDate - Returns current date
' @param {string} message - log message
' @return {string} - current date in format: "[year]-[month]-[day]"
function RALE_Logger__GetDate(message as String, level as Integer)
    m.dt.Mark()
    y = str(m.dt.getYear()).trim()
    mm = RALE_Logger__getZeroNumber(m.dt.getMonth())
    d = RALE_Logger__getZeroNumber(m.dt.getDayOfMonth())
    return y + "-" + mm + "-" + d
end function

' RALE_Logger__GetLevel - Returns current verbosity level
' @param {string} message - log message
' @return {integer} - verbosity level
function RALE_Logger__GetLevel(message as String,  level as Integer)
    return m.verbosityList[level]
end function

' RALE_Logger__GetMessage - Returns log message (needed for formating log message)
' @param {string} message - log message
' @return {string} - log message
function RALE_Logger__GetMessage(message as String, level as Integer)
    return message
end function

' RALE_Logger__getZeroNumber - Convert number to format "0[number]" if it has less then 2 digits
' @param {number} n - number for converting
' @param {number} to_length -  the necessary count of digits
' @return {string} - converted number format
function RALE_Logger__getZeroNumber(n, to_length=2)
    n = str(n).trim()
    if len(n) < to_length
        n = String(to_length - 1, "0") + n
    end if
    return n
end function


' CreateRedLines - Selector (live) view class constructor
' @return {object} - selector (live) view
Function CreateRedLines() as Object
    this = {}
    node = CreateObject("roSGNode", "Group")
    node.addFields({"isExternallyExposed": true})
    this.node = node
    this.childMap = {}

    this.setLine = RedLines_SetLine
    this.setRulerLines = RedLines_SetRulerLines
    this.removeLine = RedLines_RemoveLine
    this.removeAllLines = RedLines_RemoveAllLines

    this.resolution = m.top.getScene().getField("currentDesignResolution")

    return this
End Function

Sub RedLines_SetLine(id, position, coords)
    if (m.childMap[id] = invalid) then
        RedLines_AddLine(id, position, coords, m.node, m.childMap)
    else
        RedLines_UpdatePosition(id, coords, m.childMap)
    end if
end Sub

Sub RedLines_SetRulerLines(rulerLines)
    For Each line In rulerLines.Items()
        RedLines_AddLine(line.key, line.value.position, line.value.coords, m.node, m.childMap)
    End For
end Sub

Sub RedLines_AddLine(id, position, coords, node, childMap) as Object
    line = CreateObject("roSGNode", "Rectangle")
    line.setField("id", id)
    line.setField("color", "#00F8FF")
    line.addFields({"position": position})
    RedLines_SetLineCoords(line, coords)
    node.appendChild(line)
    childMap[id] = line
end Sub

Sub RedLines_UpdatePosition(id, coords, childMap) as Object
    line = childMap[id]
    RedLines_SetLineCoords(line, coords)
end Sub

Sub RedLines_SetLineCoords(node, coords) as Integer
    if node.position = "horizontal" then
            node.setField("translation", [coords.x,0])
            node.setField("width", 1)
            node.setField("height", m.resolution.height)
        end if
        if node.position = "vertical" then
            node.setField("translation", [0,coords.y])
            node.setField("width", m.resolution.width)
            node.setField("height", 1)
        end if
end Sub

Sub RedLines_RemoveLine(id)
    line = m.childMap[id]
    m.node.removeChild(line)
    m.childMap[id] = invalid
end Sub

Sub RedLines_RemoveAllLines()
    childrenList = m.node.getChildren(-1,0)
    m.node.removeChildren(childrenList)
    m.childMap = {}
end Sub


' CreateSelectorView - Selector (live) view class constructor
' @return {object} - selector (live) view
Function CreateSelectorView() as Object
    view = CreateObject("roSGNode", "Group")

    m.resolution = m.top.getScene().getField("currentDesignResolution")
    m.resWidth = m.resolution.width
    m.resHeight = m.resolution.height

    children = [
        {subtype : "Rectangle", fields : {id : "l"}}
        {subtype : "Rectangle", fields : {id : "r"}}
        {subtype : "Rectangle", fields : {id : "b"}}
        {subtype : "Rectangle", fields : {id : "t"}}

        {subtype : "Rectangle", fields : {id : "horiz"}}
        {subtype : "Rectangle", fields : {id : "vert"}}


        {subtype : "Rectangle", fields : {id : "leftLine"}}
        {subtype : "Rectangle", fields : {id : "topLine"}}
        {subtype : "Rectangle", fields : {id : "rightLine"}}
        {subtype : "Rectangle", fields : {id : "bottomLine"}}

        {subtype : "Label", fields : {id : "leftCords"}}
        {subtype : "Label", fields : {id : "topCords"}}
        {subtype : "Label", fields : {id : "rightCords"}}
        {subtype : "Label", fields : {id : "bottomCords"}}

        {subtype : "Rectangle", fields : {id : "fill", color :  "#ffffff44"}}
        {subtype : "Timer",     fields : {id : "timer", duration : 1 / 60, repeat : true}}
    ]

    viewObject = NodeUtils_AddChildrenToNode(view, children)
    childrenMap = {}
    for each child in viewObject.children
        node = child.node
        childrenMap[node.id] = node
    end for

    interface = [
        {id:"width", type:"float", value : "1280", onChange : "SelectorView_UpdateView"}
        {id:"height", type:"float", value : "40", onChange : "SelectorView_UpdateView"}
        {id:"border", type:"float", value : "2", onChange : "SelectorView_UpdateView"}
        {id:"oldBoundingRect", type:"assocarray" }
        {id:"boundingRect", type:"assocarray", onChange : "SelectorView_UpdateViewFromBRect"}
        {id:"color", type:"color", value : "#FFFFFF", onChange : "SelectorView_UpdateColors"}
        {id:"attachedView", type:"node", onChange : "SelectorView_AttachToView"}
        {id:"isExternallyExposed", type:"boolean", value : "true"}
        {id:"childrenMap", type:"assocarray", value : childrenMap}
    ]
    NodeUtils_AddInterfaceToNode(view, interface)

    timer = view.childrenMap.timer
    timer.observeField("fire","SelectorView_UpdateViewPosition")
    timer.control = "start"

    return view
End Function

' NodeUtils_AddInterfaceToNode - Adds interface to node
' @param {object} node - node
' @param {object} interface - interface
' @return {boolean} - is interface was added
Function NodeUtils_AddInterfaceToNode(node, interface as Object) as Boolean
    if node = invalid OR interface = invalid then return false
    for each field in interface
        NodeUtils_AddNodeInterfaceField(node, field)
    end for
    return true
End Function

' NodeUtils_AddNodeInterfaceField - Adds interface field to node
' @param {object} node - node
' @param {object} fieldConfig - field config
' @return {boolean} - is interface was added
Function NodeUtils_AddNodeInterfaceField(node, fieldConfig as Object) as Boolean
    if node = invalid OR fieldConfig = invalid then return false
    if fieldConfig.id = invalid then return false
    if fieldConfig.type = invalid then return false

    if fieldConfig.alwaysNotify = invalid then fieldConfig.alwaysNotify = true

    if node.hasField(fieldConfig.id) then return false

    node.addField(fieldConfig.id, fieldConfig.type, fieldConfig.alwaysNotify)

    if not node.hasField(fieldConfig.id) then return false

    if fieldConfig.value <> invalid then
        node[fieldConfig.id] = fieldConfig.value
    end if

    if fieldConfig.onChange <> invalid then
        node.observeField(fieldConfig.id, fieldConfig.onChange)
    end if

    return true
End Function

' NodeUtils_AddChildrenToNode - Adds children to node
' @param {object} node - node
' @param {object} childrenConfig - children config
' @return {object} - view object
Function NodeUtils_AddChildrenToNode(node, childrenConfig as Object) as Object
    if node = invalid then return invalid
    viewObject = {node : node, children : []}
    if childrenConfig <> invalid then
        for each childConfig in childrenConfig
            childObject = NodeUtils_AddChildToNode(node, childConfig)
            viewObject.children.push(childObject)
        end for
    end if

    return viewObject
End Function

' NodeUtils_AddChildToNode - Adds child to node
' @param {object} node - node
' @param {object} childConfig - child config
' @return {object} - view object
Function NodeUtils_AddChildToNode(node, childConfig) as Object
    if node = invalid or childConfig = invalid then return invalid
    if childConfig.subtype = invalid then return invalid
    view = node.CreateChild(childConfig.subtype)
    if view = invalid then return invalid
    if childConfig.fields <> invalid then view.setFields(childConfig.fields)
    return NodeUtils_AddChildrenToNode(view, childConfig.children)
End Function

' NumberToFixed - formats a number using fixed-point notation
' @param {float, double} number - formated number
' @param {integer} digits - the number of digits to appear after the decimal point
' @return {string} - a string representing the given number using fixed-point notation
Function NumberToFixed(number, digits) as String
    str = number.toStr()
    arr = str.split(".")

    if arr.count() > 1 and digits > 0 then
        return arr[0] + "." + Left(arr[1], digits)
    end if

    return arr[0]
End Function

' SelectorView_UpdateView - width, height and border change event handler. Updates Selector (live) view
' @param {object} event - event data
Sub SelectorView_UpdateView(event)
    node = event.getRoSGNode()
    border = node.border
    width  = node.width
    height = node.height
    x = node.boundingRect.x
    y = node.boundingRect.y
    rightPos = x + width + border*2
    bottomPos = y + height + border*2

    l = node.childrenMap.l
    l.width = border
    l.height = height + border*2
    l.translation = [-border, -border]

    r = node.childrenMap.r
    r.width = border
    r.height = height + border*2
    r.translation = [width, -border]

    t = node.childrenMap.t
    t.width = width + border*2
    t.height = border
    t.translation = [-border, -border]

    b = node.childrenMap.b
    b.width = width + border*2
    b.height = border
    b.translation = [-border, height]

    horiz = node.childrenMap.horiz
    horiz.width = width
    horiz.height = border
    horiz.translation = [0, (height - border) / 2]

    vert = node.childrenMap.vert
    vert.width = border
    vert.height = height
    vert.translation = [(width - border) / 2, 0]

    leftLine = node.childrenMap.leftLine
    leftLine.width = x
    leftLine.height = border
    leftLine.translation = [-x, (height - border) / 2]

    topLine = node.childrenMap.topLine
    topLine.width = border
    topLine.height = y
    topLine.translation = [(width - border) / 2, -y]

    rightLine = node.childrenMap.rightLine
    rightLine.width = m.resWidth - x + 10
    rightLine.height = border
    rightLine.translation = [width + border, (height - border) / 2]

    bottomLine = node.childrenMap.bottomLine
    bottomLine.width = border
    bottomLine.height = m.resHeight - y + 10
    bottomLine.translation = [(width - border) / 2, height + border]

    leftCords = node.childrenMap.leftCords
    leftCords.font.size = 20
    leftCords.color = "#FF0000"
    leftCords.text = NumberToFixed(x, 0)
    leftCords.translation = [-x/2 - 10, (height - border) / 2 - 20]

    topCords = node.childrenMap.topCords
    topCords.font.size = 20
    topCords.color = "#FF0000"
    topCords.text = NumberToFixed(y, 0)
    topCords.translation = [(width - border) / 2 + 10, -y/2 - 10]

    rightCords = node.childrenMap.rightCords
    rightCords.font.size = 20
    rightCords.color = "#FF0000"
    rightCords.text = NumberToFixed(m.resWidth - x - width, 0)
    rightCords.translation = [width + (m.resWidth - rightPos)/2 - 5, (height - border) / 2 - 20]

    bottomCords = node.childrenMap.bottomCords
    bottomCords.font.size = 20
    bottomCords.color = "#FF0000"
    bottomCords.text = NumberToFixed(m.resHeight - y - height, 0)
    bottomCords.translation = [(width - border) / 2 + 10, height + (m.resHeight - bottomPos)/2 - 5]

    fill = node.childrenMap.fill
    fill.width = width
    fill.height = height
End Sub

' SelectorView_UpdateColors - color change event handler. Updates Selector (live) view color
' @param {object} event - event data
Sub SelectorView_UpdateColors(event)
    node = event.getRoSGNode()
    for each view in node.getchildren(-1,0)
        if view.isSubtype("Rectangle") and view.id <> "fill" then view.color = node.color
    end for
End Sub

' SelectorView_UpdateViewFromBRect - boundingRect change event handler.
'                             Updates Selector (live) view translation, width and height
' @param {object} event - event data
Sub SelectorView_UpdateViewFromBRect(event)
    node = event.getRoSGNode()
    boundingRect = node.boundingRect
    if boundingRect <> Invalid then
        node.setFields({
            translation : [boundingRect.x, boundingRect.y]
            width : boundingRect.width
            height : boundingRect.height
        })
    end if
End Sub

' isBoundingRectChanged - checks is bounding rect was changed
' @param {object} br - node bounding rect
' @param {object} node - node
' @return {boolean} - true if node bounding rect was changed
Sub isBoundingRectChanged(br, node) as Boolean
    o = node.oldBoundingRect
    if o = Invalid then
        node.oldBoundingRect = br
        return true
    end if
    if o.x = br.x and o.y = br.y and o.width = br.width and o.height = br.height  then
        return false
    else
        node.oldBoundingRect = br
        return true
    end if
End Sub

' SelectorView_UpdateViewPosition - interval event handler. Updates selector (live) view position
' @param {object} event - node bounding rect
Sub SelectorView_UpdateViewPosition(event)
    timer = event.getRoSGNode()
    node = timer.getparent()

    if node.attachedView <> Invalid then
        boundingRect = node.attachedView.sceneboundingRect()
    else
        boundingRect = {x: -100, y: -100, width: 0, height: 0}
    end if

    if isBoundingRectChanged(boundingRect, node) then
        node.boundingRect = boundingRect
    end if
End Sub


' getCommandMap - Defines map that contains all RALE commands handlers
' @return {object} - handlers map
Sub getCommandMap() as Object
    return {
        "init" : "UIThread_init",

        ' Config commands
        "showSelectorView" : "UIThread_showSelectorView",
        "hideSelectorView" : "UIThread_hideSelectorView",

        ' Node commands
        "selectNode" : "UIThread_selectNode",
        "updateNode" : "UIThread_updateNode",
        "getNodeData" : "UIThread_getNodeData",

        ' Tree View commands
        "getItemList" : "UIThread_getItemList",
        "getNodeTree" : "UIThread_getNodeTree",
        "getNodeById" : "UIThread_getNodeById",
        "getNodeByName" : "UIThread_getNodeByName",

        ' Children commands
        "addChild" : "UIThread_addChild",
        "removeChild" : "UIThread_removeChild",
        "moveChild" : "UIThread_moveChild",

        ' Field commands
        "setField" : "UIThread_setField",
        "removeField" : "UIThread_removeField",

        ' Focus commands
        "setFocus" : "UIThread_setFocus",
        "selectFocusedNode" : "UIThread_selectFocusedNode",

        ' Bounding Rect commands
        "setBoundingRect" : "UIThread_setBoundingRect",

        ' Registry commands
        "getRegistrySections"   : "UIThread_getRegistrySections",
        "clearRegistry"         : "UIThread_clearRegistry",
        "addRegistrySection"    : "UIThread_addRegistrySection",
        "removeRegistrySection" : "UIThread_removeRegistrySection",
        "addRegistryField"      : "UIThread_addRegistryField",
        "removeRegistryField"   : "UIThread_removeRegistryField",
        "editRegistryField"     : "UIThread_editRegistryField",

        ' Logger commands
        "setLogVerbosity" : "UIThread_setLogVerbosity",
        "setLogFormat"    : "UIThread_setLogFormat",
        "log"             : "UIThread_log"

        ' Ruler lines commands
        "setRulerLine"             : "UIThread_setRulerLine",
        "setRulerLines"            : "UIThread_setRulerLines",
        "removeRulerLine"          : "UIThread_removeRulerLine",
        "removeAllRulerLines"      : "UIThread_removeAllRulerLines",
    }
End Sub

' callCommand - Call RALE command functuin from UI thread
' @param {string} command - command name
' @param {object} args - command arguments
' @return {object} - response of RALE command
Sub callCommand(command, args) as Object
    return m.top.callFunc(command, args)
End Sub

' UIThread_init - RALE "init" command
' @param {object} args - command arguments
' @return {object} - response of command. Contains RALE version and session id
Sub UIThread_init(args) as Object
    root = m.top.GetScene()

    m.currentNode  = root
    m.currentPath  = []

    if m.selectorView = Invalid then
        m.selectorView = CreateSelectorView()
        m.selectorView.color = "#ff0000"
        m.selectorView.opacity = 0.6
        m.showSelectorView = true
        root.appendChild(m.selectorView)
    end if

    if m.redLines = Invalid then
        m.redLines = CreateRedLines()
        root.appendChild(m.redLines.node)
    else
        UIThread_removeAllRulerLines({})
    end if

    if args.logVerbosity >= 0 then
        UIThread_setLogVerbosity({ level: args.logVerbosity })
    end if

    if FW_IsString(args.logFormat) then
        UIThread_setLogFormat({ format: args.logFormat })
    end if

    m.logger.info("RALE Initialized")
    return { raleVersion: m.raleVersion, sessionid: m.sessionId }
End Sub

'=======================
' Config commands
'=======================

' UIThread_showSelectorView - RALE "showSelectorView" command handler. Shows Selector (Live) View
' @param {object} args - command arguments
Sub UIThread_showSelectorView(args) as Object
    m.showSelectorView = true
    setSelectorView(m.currentNode, type(m.currentNode), m.currentPath)
    m.logger.debug("Selector View was disabled")
End Sub

' UIThread_hideSelectorView - RALE "hideSelectorView" command handler. Hides Selector (Live) View
' @param {object} args - command arguments
Sub UIThread_hideSelectorView(args) as Object
    m.showSelectorView = false
    setSelectorView(m.currentNode, type(m.currentNode), m.currentPath)
    m.logger.debug("Selector View was enabled")
End Sub

'=======================
' Node commands
'=======================

' UIThread_selectNode - RALE "selectNode" command handler. Selects node by path
' @param {object} args - command arguments
' @return {object} - response of command. Contains node path and node data (id, type, fields, layout etc.)
Sub UIThread_selectNode(args) as Object
    path = args["path"]

    root = m.top.getScene()
    node = RALE_getNodeByPath(root, path)
    if node = Invalid then return getError("Invalid Path")

    nodeType = type(node)

    if nodeType <> "roSGNode" and nodeType = "roArray" and nodeType = "roAssociativeArray" then
        return getError("Invalid Node Type")
    end if

    if nodeType = "roSGNode" and node.isExternallyExposed <> Invalid then
        return getError("Node Is Externally Exposed")
    end if

    if nodeType <> "roSGNode" or not node.IsSameNode(m.currentNode) then
        m.currentPath = path
        m.currentNode = node
    end if

    setSelectorView(node, nodeType, path)

    m.logger.debug("Node selected: " + FW_AsString(m.currentNode))
    return {
        path: m.currentPath,
        node: getNodeData(m.currentNode, m.currentPath, root)
    }
End Sub

' UIThread_updateNode - RALE "updateNode" command handler. Updates selected node
' @param {object} args - command arguments
' @return {object} - response of command. Contains node path and data (id, type, fields, layout etc.)
Sub UIThread_updateNode(args) as Object
    return {
        path: m.currentPath,
        node: getNodeData(m.currentNode, m.currentPath, Invalid)
    }
End Sub

' UIThread_getNodeData - RALE "getNodeData" command handler. Returns selected node data
' @param {object} args - command arguments
' @return {object} - response of command. Node data (id, type, fields, layout etc.)
Sub UIThread_getNodeData(args) as Object
    path = args["path"]

    if path = Invalid then
        path = m.currentPath
        node = m.currentNode
    else
        root = m.top.getScene()
        node = RALE_getNodeByPath(root, path)
        if node = Invalid then return getError("Invalid Path")
    end if

    return getNodeData(node, path, Invalid)
End Sub

'=======================
' Tree View commands
'=======================

' UIThread_getItemList - RALE "getItemList" command handler. Returns node children and fields, by node path
' @param {object} args - command arguments
' @return {object} - response of command. List of node children and fields
Sub UIThread_getItemList(args) as Object
    path = args["path"]

    root = m.top.getScene()
    node = RALE_getNodeByPath(root, path)
    if node = Invalid then return getError("Invalid Path")

    return getItemList(node, path)
End Sub

' UIThread_getNodeTree - RALE "getNodeTree" command handler. Returns children hierarchy by node path
' @param {object} args - command arguments
' @return {object} - response of command. Node children hierarchy
Sub UIThread_getNodeTree(args) as Object
    path = args["path"]
    maxLevel = args["maxLevel"]

    root = m.top.getScene()
    node = RALE_getNodeByPath(root, path)
    index = RALE_getNodeIndexByPath(path)
    if node = Invalid then return getError("Invalid Path")

    return getNodeTree(node, index, maxLevel)
End Sub

' UIThread_getNodeById - RALE "getNodeById" command handler. Returns node with requested id
' @param {object} args - command arguments
' @return {object} - response of command. Found node data
Sub UIThread_getNodeById(args) as Object
    path = args["path"]
    id = args["id"]

    if id = Invalid then return getError("id is required")

    root = m.top.getScene()
    rootNode = RALE_getNodeByPath(root, path)
    if rootNode = Invalid then return getError("Invalid Path")

    foundNode = getNodeById(rootNode, id)
    foundPath = RALE_getNodePath(foundNode, root)

    return getNodeData(foundNode, foundPath, root)
End Sub

' UIThread_getNodeByName - RALE "getNodeByName" command handler. Returns node with requested name
' @param {object} args - command arguments
' @return {object} - response of command. Found node path
Sub UIThread_getNodeByName(args) as Object
    path = args["path"]
    name = args["name"]

    if name = Invalid then return getError("name is required")

    root = m.top.getScene()
    rootNode = RALE_getNodeByPath(root, path)
    if rootNode = Invalid then return getError("Invalid Path")

    foundNode = getNodeByName(rootNode, name)
    foundPath = RALE_getNodePath(foundNode, root)

    return getNodeData(foundNode, foundPath, root)
End Sub

'=======================
' Children commands
'=======================

' UIThread_addChild - RALE "addChild" command handler. Adds new child to node by path (if no path adds to selected node)
' @param {object} args - command arguments
' @return {object} - response of command. Contains node children hierarchy and index
Sub UIThread_addChild(args) as Object
    childType = args["type"]
    path = args["path"]

    if not FW_IsString(childType) then return getError("childType is required")

    index = FW_AsInteger(args["index"])
    if index = 0 AND FW_AsString(args["index"]) <> "0" then index = Invalid

    if path <> Invalid then
        root = m.top.getScene()
        node = RALE_getNodeByPath(root, path)
        if node = Invalid then return getError("Invalid Path")
    else
        node = m.currentNode
        path = m.currentPath
    end if

    result = addChild(node, childType, index)
    if result.success = true then
        index = RALE_getNodeIndexByPath(path)
        setNodeField(result.child, "rale_new_child", true, "boolean")
        return {
            tree: getNodeTree(result.child, index, 50),
            childindex: result.index
        }
    else
        return result
    end if
End Sub

' UIThread_removeChild - RALE "removeChild" command handler. Removes child from node by path (if no path removes from selected node)
' @param {object} args - command arguments
' @return {object} - response of command
Sub UIThread_removeChild(args) as Object
    index = FW_AsInteger(args["index"])
    path = args["path"]

    if index = 0 AND FW_AsString(args["index"]) <> "0" then return getError("index is required")

    if path <> Invalid then
        root = m.top.getScene()
        node = RALE_getNodeByPath(root, path)
        if node = Invalid then return getError("Invalid Path")
    else
        node = m.currentNode
        path = m.currentPath
    end if

    return removeChild(node, index)
End Sub

' UIThread_moveChild - RALE "moveChild" command handler. Moves selected node child
' @param {object} args - command arguments
' @return {object} - response of command
Sub UIThread_moveChild(args) as Object
    fromIndex = FW_AsString(args["fromIndex"])
    fromIndexInt = FW_AsInteger(fromIndex)
    if fromIndexInt = 0 AND fromIndex <> "0" then return getError("fromIndex is required")

    toIndex = FW_AsString(args["toIndex"])
    toIndexInt = FW_AsInteger(toIndex)
    if toIndexInt = 0 AND toIndex <> "0" then return getError("toIndex is required")

    return moveChild(m.currentNode, fromIndexInt, toIndexInt)
End Sub

'=======================
' Fields commands
'=======================

' UIThread_setField - RALE "setField" command handler. Sets new value into node field (if the field doesn't exist creates it)
' @param {object} args - command arguments
' @return {array} - response of command. Node field list
Sub UIThread_setField(args) as Object
    field = FW_AsString(args["field"])
    fieldType = args["type"]
    fieldValue = args["value"]

    if field = "" then return getError("Field ID is required")
    if RALE_convertToType(fieldValue, FW_AsString(fieldType)) = Invalid then return getError("Invalid Field Type or Value")

    path = m.currentPath
    nodeType = type(m.currentNode)

    if nodeType = "roSGNode" then
        setNodeField(m.currentNode, field, fieldValue, fieldType)
    else
        m.currentNode = setObjField(path, field, fieldValue, fieldType)
    end if

    m.logger.debug("Field '" + field + "' of selected node was set to " + FW_AsString(fieldValue))
    return getFieldList(m.currentNode)
End Sub

' UIThread_removeField - RALE "removeField" command handler. Remove field from node by id
' @param {object} args - command arguments
' @return {array} - response of command. Node field list
Sub UIThread_removeField(args) as Object
    field = args["field"]
    if field = Invalid then return getError("Field ID is required")

    node = m.currentNode
    nodeType = type(node)

    if nodeType = "roSGNode" then
       ? ">>>>>>>>>>>>>>>>>>>>>>>"
        ? formatJson(node[field])
        ? ">>>>>>>>>>>>>>>>>>>>>>>"
    else if nodeType = "roAssociativeArray" or nodeType = "roArray" then
      if nodeType = "roArray" then field = FW_AsInteger(field)
        ? ">>>>>>>>>>>>>>>>>>>>>>>"
        ? formatJson(node[field])
        ? ">>>>>>>>>>>>>>>>>>>>>>>"
    end if
    return getFieldList(node)
End Sub

'=======================
' Focus commands
'=======================

' UIThread_setFocus - RALE "setFocus" command handler. Sets focus in node by path
' @param {object} args - command arguments
' @return {object} - response of command. Status
Sub UIThread_setFocus(args) as Object
    path = args["path"]

    node = m.top.getScene()
    node = RALE_getNodeByPath(node, path)
    if node = Invalid then return getError("Invalid Path")

    m.logger.debug(FW_AsString(node) + " was focused")
    node.setFocus(true)
    return { success: true }
End Sub

' UIThread_selectFocusedNode - RALE "selectFocusedNode" command handler. Select focused node
' @param {object} args - command arguments
' @return {object} - response of command. Contains node path and data (id, type, fields, layout etc.)
Sub UIThread_selectFocusedNode(args) as Object
    root = m.top.getScene()
    node = getFocusedNodeObj(root)
    if m.currentNode.IsSameNode(node) then
        return {
            path: m.currentPath,
            node: getNodeData(node, m.currentPath, root)
        }
    else
        path = RALE_getNodePath(node, root)
        m.currentNode = node
        m.currentPath = path
        setSelectorView(node, type(node), path)
        m.logger.debug("Node selected: " + FW_AsString(node))
        return {
            path: path,
            node: getNodeData(node, path, root)
        }
    end if
End Sub

'=======================
' Bounding Rect commands
'=======================

' UIThread_setBoundingRect - RALE "setBoundingRect" command handler. Sets properties into selected node layout
' @param {object} args - command arguments
' @return {object} - response of command. Node sceneBoundingRect
Sub UIThread_setBoundingRect(args) as Object
    boundingRect = args["boundingrect"]
    if boundingRect = Invalid then return getError("boundingrect is required")

    node = m.currentNode
    if type(node) <> "roSGNode" then return getError("Invalid Node Type")
    currentBoundingRect = node.sceneBoundingRect()

    if currentBoundingRect <> Invalid then
        deltaX = 0
        deltaY = 0
        deltaWidth = 0
        deltaHeight = 0

        if boundingRect.x <> Invalid and boundingRect.y <> Invalid then
            deltaX = currentBoundingRect.x - boundingRect.x
            deltaY = currentBoundingRect.y - boundingRect.y
        end if

        if boundingRect.width <> Invalid and boundingRect.height <> Invalid then
            deltaWidth = currentBoundingRect.width - boundingRect.width
            deltaHeight = currentBoundingRect.height - boundingRect.height
        end if

        fields = {}

        if node.hasField("translation") AND (deltaY <> 0 or deltaX <> 0) then
            fields.translation = [node.translation[0] - deltaX, node.translation[1] - deltaY]
            m.logger.debug("Selected node translation was set to " + FW_AsString(fields.translation))
        end if

        if node.hasField("width") AND deltaWidth <> 0 then
            if node.width = 0 AND deltaWidth > 0 then
                fields.width = boundingRect.width
            else
                fields.width = node.width - deltaWidth
            end if
            m.logger.debug("Selected node width was set to " + FW_AsString(fields.width))
        end if

        if node.hasField("height") AND deltaHeight <> 0 then
            if node.height = 0 AND deltaHeight > 0 then
                fields.height = boundingRect.height
            else
                fields.height = node.height - deltaHeight
            end if
            m.logger.debug("Selected node height was set to " + FW_AsString(fields.height))
        end if

        node.setFields(fields)
    end if
    return node.sceneBoundingRect()
End Sub

'=======================
' Layout ruler commands
'=======================
' UIThread_setRulerLine - TBD
Sub UIThread_setRulerLine(args) as Object
    m.redLines.setLine(FW_AsString(args.id), args.position, args.coords)
    return { success: true }
End Sub

' UIThread_setRulerLines - TBD
Sub UIThread_setRulerLines(args) as Object
    if args.rulerLines.Count() >= 0 then
        m.redLines.setRulerLines(args.rulerLines)
    end if
    return { success: true }
End Sub

' UIThread_removeRulerLine - TBD
Sub UIThread_removeRulerLine(args) as Object
    m.redLines.removeLine(FW_AsString(args.id))
    return { success: true }
End Sub

' UIThread_removeRulerLine - TBD
Sub UIThread_removeAllRulerLines(args) as Object
    m.redLines.removeAllLines()
    return { success: true }
End Sub

'=======================
' Registry commands
'=======================

' UIThread_getRegistrySections - TBD
Sub UIThread_getRegistrySections(args) as Object
    return getRegistrySections()
End Sub

' UIThread_addRegistrySection - TBD
Sub UIThread_clearRegistry(args) as Object
    return clearRegistry()
End Sub

' UIThread_addRegistrySection - TBD
Sub UIThread_addRegistrySection(args) as Object
    name = args.name
    section = args.section

    if not FW_IsString(name) or name = "" then return getError("Invalid name")
    if not FW_IsAssociativeArray(section) then return getError("Invalid section. Expected an object")

    return addRegistrySection(name, section)
End Sub

' UIThread_removeRegistrySection - TBD
Sub UIThread_removeRegistrySection(args) as Object
    name = args.name

    if not FW_IsString(name) or name = "" then return getError("Invalid name")

    return removeRegistrySection(name)
End Sub

' UIThread_addRegistryField - TBD
Sub UIThread_addRegistryField(args) as Object
    sectionName = args.sectionName
    key = args.key
    value = args.value

    if not FW_IsString(sectionName) or sectionName = "" then return getError("Invalid section name")
    if not FW_IsString(key) or key = "" then return getError("Invalid key")
    if not FW_IsString(value) then return getError("Invalid value")

    return addRegistryField(sectionName, key, value)
End Sub

' UIThread_removeRegistryField - TBD
Sub UIThread_removeRegistryField(args) as Object
    sectionName = args.sectionName
    key = args.key

    if not FW_IsString(sectionName) or sectionName = "" then return getError("Invalid section name")
    if not FW_IsString(key) or key = "" then return getError("Invalid key")

    return removeRegistryField(sectionName, key)
End Sub

' UIThread_editRegistryField - TBD
Sub UIThread_editRegistryField(args) as Object
    sectionName = args.sectionName
    key = args.key
    newKey = args.newKey
    newValue = args.newValue

    if not FW_IsString(sectionName) or sectionName = "" then return getError("Invalid section name")
    if not FW_IsString(key) or key = "" then return getError("Invalid key")
    if not FW_IsString(newKey) or newKey = "" then return getError("Invalid newKey")

    return editRegistryField(sectionName, key, newKey, newValue)
End Sub

' UIThread_log - TBD
Sub UIThread_log(args) as Object
    m.logger.logMessage(args.message, m.logger.verbosityMap[args.status])
End Sub

' UIThread_setLogVerbosity - TBD
Sub UIThread_setLogVerbosity(args) as Object
    level = args.level

    if not FW_IsInteger(level) then return getError("Invalid level")

    m.logger.setVerbosity(args.level)
    return { success: true }
End Sub

' UIThread_setLogFormat - TBD
Sub UIThread_setLogFormat(args) as Object
    format = args.format

    if not FW_IsString(format) then return getError("Invalid format")

    m.logger.setFormat(args.format)
    return { success: true }
End Sub

'=======================
' Helpers functions
'=======================

' getLayout - Returns node layout fields (boundingRect, resolution, isMovable, isHeightResizable, isWidthResizable)
' @param {object} node - node
' @param {object} root - root of nodes (main scene)
' @return {object} - node layout
Sub getLayout(node, root) as Object
    if not FW_IsSGNode(node) then return getError("Invalid Node Type")

    if root = Invalid then root = m.top.getScene()

    parent = node.getParent()

    isWidthResizable = node.hasField("width")
    isHeightResizable = node.hasField("height")
    isMovable = false

    if parent <> Invalid and not m.sceneBG.isSameNode(node)  then
        isMovable = node.hasField("translation") and parent.ParentSubtype("LayoutGroup") <> ""
    end if

    return {
        isMovable : isMovable,
        isHeightResizable : isHeightResizable,
        isWidthResizable : isWidthResizable,
        boundingRect : node.sceneBoundingRect(),
        resolution : root.getField("currentDesignResolution")
    }
End Sub

' getItemObj - Returns node object
' @param {object} item - node or filed
' @param {string} index - field id or child index
' @return {object} - node data object
Sub getItemObj(item, index) as Dynamic
    itemType = type(item)

    if itemType = "roSGNode" then
        return {
            index: index,
            id: item.id,
            childrenCount: item.getChildCount(),
            subtype: item.subtype(),
            type: itemType,
            value: "{object}"
            isExposed: FW_AsBoolean(item.isExternallyExposed)
        }
    else if itemType = "roArray" or itemType = "roAssociativeArray" then
        return {
            id: index,
            type: itemType,
            value: "{object}"
        }
    else
        return {
            id: index,
            type: itemType,
            value: FW_AsString(item)
        }
    end if
End Sub

' getFieldList - Returns node field list
' @param {object} node - node
' @return {array} - list of fields
Sub getFieldList(node) as Object
    nodeType = type(node)

    if nodeType = "roSGNode" then
        fields = node.getFields()
    else if nodeType = "roArray" or nodeType = "roAssociativeArray" then
        fields = node
    else
        return getError("Invalid Node Type")
    end if

    fieldList = {}

    result = 0
    if type(fields) = "roArray" then
        count = fields.count() - 1
        for i = 0 to count
            id = i.ToStr()
            fieldList[id] = { item: getItemObj(fields[i], i) }
            fieldList[id].item.id = i
        end for
    else
        keys = fields.keys()
        for each fieldId in keys
            fieldList[fieldId] = { item: getItemObj(fields[fieldId], fieldId) }
            if nodeType = "roSGNode" then fieldList[fieldId].item.fieldType = node.getFieldType(fieldId)
        end for
    end if

    return fieldList
End Sub

' getChildList - Returns node children list
' @param {object} node - node
' @return {array} - list of children
Sub getChildList(node) as Object
    nodeType = type(node)

    if nodeType = "roSGNode" then
        childList = []
        children = node.getChildren(-1, 0)
        count = children.count()
        if count > 0 then
            count--
            for i = 0 to count
                if children[i] <> Invalid then
                    childList[i] = { item: getItemObj(children[i], i) }
                end if
            end for
        end if
        return childList
    else
        return getError("Invalid Node Type")
    end if
End Sub

' getItemList - Returns node children list and node data
' @param {object} node - node
' @param {object} index - node index
' @return {object} - node data object and list of node children
Sub getItemList(node, index) as Object
    item = { item: getItemObj(node, index) }
    nodeType = type(node)
    if nodeType = "roSGNode" then
        item.childList = getChildList(node)
    else
        return getError("Invalid Node Type")
    end if
    return item
End Sub

' getNodeTree - Goes through node children and returns node children hierarchy
' @param {object} node - node or filed
' @param {string} id - node index or filed id
' @return {array} - node children hierarchy
Sub getNodeTree(node, id, maxLevel) as Object
    item = {
        item: getItemObj(node, id),
        childList: []
    }

    result = RALE_forEachChild(node, { maxLevel: maxLevel }, getNodeTreeCallback, { item: item })

    if not result then
        return getError("Invalid Node Type")
    end if

    return item
End Sub

Sub getNodeTreeCallback(node, index, parentObj, childObj, storage) as Boolean

    if parentObj.item = Invalid then
        parentObj.item = storage.item
    end if

    childItem = {
        item : getItemObj(node, index),
        childList : []
    }

    parentObj.item.childlist[index] = childItem

    if childObj <> Invalid then
        childObj.item = childItem
    end if

    return true
End Sub

' getNodeById - Search for node by id
' @param {object} node - root node
' @param {string} id - node id
' @return {object} - found node
Sub getNodeById(rootNode, id) as Object

    if rootNode.id = id then
        return rootNode
    end if

    storage = {
        node: Invalid,
        id: id
    }

    result = RALE_forEachChild(rootNode, {}, getNodeByIdCallback, storage)

    if not result then
        return getError("Invalid Node Type")
    end if

    return storage.node
End Sub

Sub getNodeByIdCallback(node, index, parentObj, childObj, storage) as Boolean

    if node.id = storage.id then
        storage.node = node
        return false
    end if

    return true
End Sub

' getNodeByName - Search for node by name (subtype)
' @param {object} node - root node
' @param {string} name - node name (subtype)
' @return {object} - found node
Sub getNodeByName(rootNode, name) as Object

    if rootNode.subtype() = name then
        return rootNode
    end if

    storage = {
        node: Invalid,
        name: name
    }

    result = RALE_forEachChild(rootNode, {}, getNodeByNameCallback, storage)

    if not result then
        return getError("Invalid Node Type")
    end if

    return storage.node
End Sub

Sub getNodeByNameCallback(node, index, parentObj, childObj, storage) as Boolean

    if node.subtype() = storage.name then
        storage.node = node
        return false
    end if

    return true
End Sub

' getNodeData - Returns node children hierarchy
' @param {object} node - node or filed
' @param {array} path - path to node
' @param {object} root - root of nodes (main scene)
' @return {object} - node data (item, fieldlist, layout)
Sub getNodeData(node, path, root) as Object
    index = RALE_getNodeIndexByPath(path)
    if index = Invalid then return getError("Invalid Path")

    result = {
        item: getItemObj(node, index),
        fieldlist: getFieldList(node),
        layout: getLayout(node, root)
    }
    if type(node) = "roSGNode" then result.childlist = getChildList(node)

    return result
End Sub

' addChild - Adds child to node by type and index
' @param {object} node - parent node
' @param {string} childType - path to node
' @param {string} index - child index
' @return {object} - status
Sub addChild(node, childType, index) as Object
    if not FW_IsSGNode(node) then return getError("Cannot Add Child. Invalid Node Type")

    child = CreateObject("roSGNode", childType)
    if not FW_IsSGNode(child) then return getError("Cannot Add Child. Invalid Component Type")

    childCount = node.getChildCount()
    if FW_IsInteger(index) and index < childCount then
        node.insertChild(child, index)
    else
        index = childCount
        node.appendChild(child)
    end if

    addedChild = node.getChild(index)
    if type(addedChild) = "roSGNode" and addedChild.isSameNode(child) then
        m.logger.debug("Child " + childType + " was added to " + FW_AsString(node) + " by index " + FW_AsString(index))
        return { success: true, child: addedChild, index: index }
    else
        return getError("Cannot Add Child")
    end if
End Sub

' removeChild - Removes child from node by index
' @param {object} node - parent node
' @param {string} index - child index
' @return {object} - status
Sub removeChild(node, index as Integer) as Object
    if not FW_IsSGNode(node) then return getError("Invalid Node Type")
    count = node.getChildCount()
    if FW_IsSGNode(node.getChild(index)) then
        node.removeChildIndex(index)
        if node.getChildCount() < count then
            m.logger.debug("Child with index " + FW_AsString(index) + " was removed from " + FW_AsString(node))
            return { success: true }
        end if
        return getError("Node cannot be removed")
    else
        return getError("No child with this index")
    end if
End Sub

' moveChild - Moves node child by index to another position
' @param {object} node - parent node
' @param {string} fromIndex - current child index
' @param {string} toIndex - index where you want to move
' @return {object} - status
Sub moveChild(node, fromIndex, toIndex) as Object
    if not FW_IsSGNode(node) then return getError("Invalid Node Type")

    if fromIndex >= 0 AND toIndex >= 0
        child = node.getChild(fromIndex)
        if child <> Invalid then
            node.removeChildIndex(fromIndex)
            if toIndex > fromIndex then toIndex--
            node.insertChild(child, toIndex)

            m.logger.debug("Child of " + FW_AsString(node) + " was moved from index " + FW_AsString(fromIndex) + " to index " + FW_AsString(toIndex))
            return { success: true }
        else
            return getError("No child with this index")
        end if
    else
        return getError("fromIndex and toIndex must be positive integer")
    end if
End Sub

' setSelectorView - Shows selector (live) view for node
' @param {object} node - node
' @param {string} nodeType - type of node
' @param {array} nodePath - path to node
' @return {object} - status
Function setSelectorView(node, nodeType, nodePath) as Object
    if m.selectorView <> Invalid then
        if m.showSelectorView and nodeType = "roSGNode" and nodePath.count() > 0 then
            m.selectorView.attachedView = node
        else
            m.selectorView.attachedView = Invalid
        end if
    end if
End Function

' setNodeField - Sets field into node
' @param {object} node - node
' @param {string} field - field id
' @param {dynamic} value - field value
' @param {string} fieldType - field type
Sub setNodeField(node, field, value, fieldType) as Object
    fields = {}
    if fieldType = Invalid then
        fields[field] = value
        if node.hasField(field) then
            node.setFields(fields)
        else
            node.addFields(fields)
        end if
    else
        fields[field] = RALE_convertToType(value, fieldType)
'        if node.hasField(field) and node.getFieldType(field) <> 'fieldType then
'            node.removeField(field)
'        end if
'
'        if not node.hasField(field) then
'            node.addField(field, RALE_parseType(fieldType), false)
'        end if
        node.setFields(fields)
    end if
End Sub

' setObjField - Sets field into AssociativeArray
' @param {array} parentPath - node
' @param {string} field - field id
' @param {dynamic} value - field value
' @param {string} fieldType - field type
' @return {object} - status
Sub setObjField(parentPath, field, value, fieldType) as Object
    if fieldType <> Invalid then
        value = RALE_convertToType(value, fieldType)
    end if
    return setInParentNode(parentPath, field, value)
End Sub

' setInParentNode - Sets field into parent node
' @param {array} path - path to field
' @param {string} field - field id
' @param {dynamic} value - field value
' @return {object} - parent node
Function setInParentNode(path, field, value)
    root = m.top.getScene()
    parentPath = []
    parentPath.append(path)
    nodeList = RALE_getNodeListByPath(root, path)
    if nodeList = Invalid then return getError("Invalid Path")

    index = nodeList.count() - 1
    parent = nodeList[index]
    if type(parent) = "roSGNode" then
        setNodeField(parent, field, value, Invalid)
        return parent
    end if

    while type(parent) <> "roSGNode"
        if type(parent) = "roArray" then
            field = FW_AsInteger(field)
            if field > parent.count() then
                field = parent.count()
            end if
            parent[field] = value
        else
            parent[field] = value
        end if
        value = parent
        index--
        field = path[index].field
        parent = nodeList[index]
        parentPath.pop()
    end while

    parent = RALE_getNodeByPath(root, parentPath)
    setNodeField(parent, field, value, Invalid)
    return RALE_getNodeByPath(root, path)
End Function

' setFocus - Focus node
' @param {object} node - node
Sub setFocus(node) as Object
    if not FW_IsSGNode(node) then return getError("Invalid Node Type")
    node.setFocus(true)
End Sub

' getFocusedNodeObj - Returns focused node
' @param {object} root - root
' @param {object} maxDeep - search depth
' @return {object} - focused node
Function getFocusedNodeObj(root, maxDeep = 25) as Object
    node = root
    focusedChild = node.focusedChild
    while maxDeep > 0 AND focusedChild <> Invalid AND not node.isSameNode(focusedChild)
        node = focusedChild
        focusedChild = node.focusedChild
        maxDeep--
    end while
    return node
End Function

' getRegistrySections - Returns map of roRegistry
' @return {object} - sections
Function getRegistrySections() as Object
    sections = {}

    RALE_forEachRegistryField(getRegistrySectionsCallback, sections)

    return sections
End Function

Sub getRegistrySectionsCallback(value, key, section, sections) as Boolean
    if not FW_IsAssociativeArray(sections[section]) then
        sections[section] = {}
    end If

    sections[section][key] = value

    return true
End Sub

' clearRegistry - Clear roRegistry
Function clearRegistry() as Object
    RALE_forEachRegistrySection(clearRegistryCallback, {})

    return { success: true }
End Function

Sub clearRegistryCallback(section, sectionName, storage) as Object
    return removeRegistrySection(sectionName)
End Sub

' addRegistrySection - TBD
' @return {object} - sections
Function addRegistrySection(sectionName, section) as Object
    RegistrySection = CreateObject("roRegistrySection", sectionName)
    keys = section.keys()

    for each key in keys
        RegistrySection.write(key, section[key])
    end for

    RegistrySection.flush()
    m.logger.debug("Registry section " + sectionName + " was added to roRegistry")

    return  { success: true }
End Function

' removeRegistrySection - TBD
' @return {object} - sections
Function removeRegistrySection(sectionName) as Object
    Registry = CreateObject("roRegistry")

    success = Registry.delete(sectionName)

    Registry.flush()

    m.logger.debug("Registry section " + sectionName + " was removed from roRegistry")

    return { success: success }
End Function

' addRegistryField - TBD
' @return {object} - sections
Function addRegistryField(sectionName, key, value) as Object
    RegistrySection = CreateObject("roRegistrySection", sectionName)

    success = RegistrySection.write(key, value)

     m.logger.debug("Field " + key + " with value " + value + " was added to " + sectionName + " registry section")

    return { success: success }
End Function

' removeRegistryField - TBD
' @return {object} - sections
Function removeRegistryField(sectionName, key) as Object
    RegistrySection = CreateObject("roRegistrySection", sectionName)

    success = RegistrySection.delete(key)

     m.logger.debug("Field " + key + " was removed from " + sectionName + " registry section")

    return { success: success }
End Function

' getRegistrySections - TBD
' @return {object} - sections
Function editRegistryField(sectionName, key, newKey, newValue) as Object
    result = removeRegistryField(sectionName, key)

    if result.success then
        result = addRegistryField(sectionName, newKey, newValue)
    end if

    return result
End Function

' getError - Returns error object
' @param {string} message - error message
Function getError(message as String) as Object
    m.logger.error(message)
    return { error: { message: message } }
End Function


' @desc TrackerTask init function
Sub init()
    m.top.functionName = "tracker"
    m.top.control = "RUN"

    m.config = RALE_Config()
    m.logger = RALE_Logger(m.config.defaultLogLevel, m.config.logFormat)
    m.sceneBG = m.top.GetScene().getChild(0)
    m.raleVersion = "2.1.7"
    m.sessionId = CreateObject("roDeviceInfo").GetRandomUUID()

    m.logger.info("Roku Advanced Layout Editor v." + m.raleVersion)
End Sub

' tracker - TrackerTask run function
Sub tracker()
    appInfo = CreateObject("roAppInfo")
    handlersMap = getCommandMap()

    RALE_InfoLog("TrackerTask run")

    buffer = CreateObject("roByteArray")
    buffer[m.config.bufferSize] = 0
    messagePort = CreateObject("roMessagePort")
    addr = CreateObject("roSocketAddress")

    inputPort = CreateObject("roMessagePort")
    inputObj  = CreateObject("roInput")
    inputObj.SetMessagePort(inputPort)

    while True
        raleEnabled = true
        port = 0
        RALE_InfoLog("Waiting on ECP input request")
        msg = wait(0, inputPort)

        if type(msg) = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                if type(info) = "roAssociativeArray" and info.rale <> Invalid then
                    port = FW_AsInteger(info.port)
                end if

                nonDev = FW_AsBoolean(info.nonDev)

            end if
        end if

        if raleEnabled and port > m.config.minSocketPort and port < m.config.maxSocketPort then
            socketConnection(addr, messagePort, port, buffer, handlersMap, m.config)
        end if
    end while

End Sub

' socketConnection - Starts socket connection. Keep alive while connection won't be closed
' @param {object} addr - roSocketAddress
' @param {object} messagePort - roMessagePort
' @param {number} port - socket connection port
' @param {array} buffer - buffer for socket packets
' @param {object} handlersMap - map that contains all RALE commands handlers
' @param {object} config - configuration constants
' @return {string} - connection status
Sub socketConnection(addr, messagePort, port, buffer, handlersMap, config) as String
    connections = {}
    appManager = createObject("roAppManager")
    screensaverTimer = CreateObject("roTimespan")
    screensaverTimer.Mark()

    addr.setPort(port)

    tcpListen = CreateObject("roStreamSocket")
    tcpListen.setMessagePort(messagePort)
    tcpListen.setAddress(addr)
    tcpListen.notifyReadable(true)
    tcpListen.listen(4)

    wasConnected = false

    RALE_InfoLog("Start socket server on port " + FW_AsString(port))

    while True

        if not wasConnected then
            event = wait(3000, messagePort)
            if event = Invalid then
                tcpListen.close()
                RALE_WarningLog("No 'init' command received. Socket connection closed")
                return "connection timeout"
            end if
        else
            event = wait(config.commandTimeout, messagePort)
        end if

        ' Resets the screensaver timer
        if screensaverTimer.TotalMilliseconds() > config.screensaverResetTimeout then
            screensaverTimer.Mark()
            appManager.UpdateLastKeyPressTime()
        end if

        ' ? type(event)
        if type(event) = "roSocketEvent"
            wasConnected = true
            changedID = event.getSocketID()
            if changedID = tcpListen.getID() and tcpListen.isReadable()
                ' New
                newConnection = tcpListen.accept()
                if newConnection = Invalid
                    RALE_WarningLog("Connection accept failed")
                else
                    RALE_InfoLog("Accepted new connection " + FW_AsString(newConnection.getID()))

                    newConnection.notifyReadable(true)
                    newConnection.setMessagePort(messagePort)
                    connections[Stri(newConnection.getID())] = newConnection
                end if
            else
                ' Activity on an open connection
                connection = connections[Stri(changedID)]
                closed = False
                if connection.isReadable()
                    received = connection.receive(buffer, 0, 100024)
                    if received > 0
                        timer = CreateObject("roTimespan")
                        timer.Mark()

                        valueType = type(m.lastUdpPacketRemainingContents)
                        if NOT ((valueType = "String") OR (valueType = "roString")) then
                            m.lastUdpPacketRemainingContents = ""
                        end if
                        remainingString = m.lastUdpPacketRemainingContents + buffer.ToAsciiString()
                        m.lastUdpPacketRemainingContents = ""
                        'print "incoming string " remainingString
                        startIndex = 0
                        continueToLoop = true
                        while continueToLoop
                            index = remainingString.instr(startIndex, "}{")
                            if index < 0 then
                                str = remainingString
                                continueToLoop = false
                            else
                                index++
                                str = remainingString.left(index)
                                remainingString = remainingString.mid(index)
                                if remainingString.right(1) <> "}" and remainingString.instr("}{") < 0 then
                                    m.lastUdpPacketRemainingContents = remainingString
                                    exit while
                                end if
                            end if
                          end while

                          request = ParseJson(str)
                        buffer = CreateObject("roByteArray")
                        buffer[100024] = 0

                        if request <> Invalid then
                            response = {}
                            if request["command"] <> Invalid then

                                handler = handlersMap[request["command"]]
                                if handler <> Invalid then
                                    RALE_DebugLog("Handling command: " + request["command"])
                                    RALE_DebugLog("Received arguments: " + FW_AsString(request["args"]))

                                    response = callCommand(handler, request["args"])
                                else
                                    RALE_ErrorLog("No such command: " + request["command"])

                                    response = getError("No such command")
                                end if
                            end if
                            id = request.uuid
                            idLen = FW_AsString(Len(id))
                            json = FormatJson(response)
                            res = "[start][uuid:" + idLen + "]" + id + json + "[end]"

                            resList = RALE_splitStringByLength(res, 3000)
                            count = resList.count() - 1
                            for i = 0 to count
                                connection.SendStr(resList[i])
                                sleep(20)
                            end for
                            RALE_DebugLog("Command handled in: " + FW_AsString(timer.TotalMilliseconds()) + "ms")
                        end if
                    else if received=0 ' client closed
                        closed = True
                    end if
                end if
                if closed or not connection.eOK()
                    connection.close()
                    connections.delete(Stri(changedID))
                    exit while
                end if
            end if
        end if
    end while

    tcpListen.close()
    for each id in connections
        connections[id].close()
    end for

    RALE_InfoLog("Socket connection closed")

    return "connection closed"
End Sub

'IMPORTS=
'=====================
' Types
'=====================

'*************************************************
' FW_IsXmlElement - check if value contains XMLElement interface
' @param value As Dynamic
' @return As Boolean - true if value contains XMLElement interface, else return false
'*************************************************
Function FW_IsXmlElement(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifXMLElement") <> invalid
End Function

'*************************************************
' FW_IsFunction - check if value contains Function interface
' @param value As Dynamic
' @return As Boolean - true if value contains Function interface, else return false
'*************************************************
Function FW_IsFunction(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifFunction") <> invalid
End Function

'*************************************************
' FW_IsBoolean - check if value contains Boolean interface
' @param value As Dynamic
' @return As Boolean - true if value contains Boolean interface, else return false
'*************************************************
Function FW_IsBoolean(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifBoolean") <> invalid
End Function

'*************************************************
' FW_IsInteger - check if value type equals Integer
' @param value As Dynamic
' @return As Boolean - true if value type equals Integer, else return false
'*************************************************
Function FW_IsInteger(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifInt") <> invalid And (Type(value) = "roInt" Or Type(value) = "roInteger" Or Type(value) = "Integer")
End Function

'*************************************************
' FW_IsFloat - check if value contains Float interface
' @param value As Dynamic
' @return As Boolean - true if value contains Float interface, else return false
'*************************************************
Function FW_IsFloat(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifFloat") <> invalid
End Function

'*************************************************
' FW_IsDouble - check if value contains Double interface
' @param value As Dynamic
' @return As Boolean - true if value contains Double interface, else return false
'*************************************************
Function FW_IsDouble(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifDouble") <> invalid
End Function

'*************************************************
' FW_IsLongInteger - check if value contains LongInteger interface
' @param value As Dynamic
' @return As Boolean - true if value contains LongInteger interface, else return false
'*************************************************
Function FW_IsLongInteger(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifLongInt") <> invalid
End Function


'*************************************************
' FW_IsNumber - check if value contains LongInteger or Integer or Double or Float interface
' @param value As Dynamic
' @return As Boolean - true if value is number, else return false
'*************************************************
Function FW_IsNumber(value As Dynamic) As Boolean
    Return FW_IsLongInteger(value) or FW_IsDouble(value) or FW_IsInteger(value) or FW_IsFloat(value)
End Function

'*************************************************
' FW_IsList - check if value contains List interface
' @param value As Dynamic
' @return As Boolean - true if value contains List interface, else return false
'*************************************************
Function FW_IsList(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifList") <> invalid
End Function

'*************************************************
' FW_IsArray - check if value contains Array interface
' @param value As Dynamic
' @return As Boolean - true if value contains Array interface, else return false
'*************************************************
Function FW_IsArray(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifArray") <> invalid
End Function

'*************************************************
' FW_IsAssociativeArray - check if value contains AssociativeArray interface
' @param value As Dynamic
' @return As Boolean - true if value contains AssociativeArray interface, else return false
'*************************************************
Function FW_IsAssociativeArray(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifAssociativeArray") <> invalid
End Function

'*************************************************
' FW_IsSGNode - check if value contains SGNodeChildren interface
' @param value As Dynamic
' @return As Boolean - true if value contains SGNodeChildren interface, else return false
'*************************************************
Function FW_IsSGNode(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifSGNodeChildren") <> invalid
End Function

'*************************************************
' FW_IsString - check if value contains String interface
' @param value As Dynamic
' @return As Boolean - true if value contains String interface, else return false
'*************************************************
Function FW_IsString(value As Dynamic) As Boolean
    Return FW_IsValid(value) And GetInterface(value, "ifString") <> invalid
End Function

'*************************************************
' FW_IsNotEmptyString - check if value contains String interface and length more 0
' @param value As Dynamic
' @return As Boolean - true if value contains String interface and length more 0, else return false
'*************************************************
Function FW_IsNotEmptyString(value As Dynamic) As Boolean
    Return FW_IsString(value) and len(value) > 0
End Function

'*************************************************
' FW_IsDateTime - check if value contains DateTime interface
' @param value As Dynamic
' @return As Boolean - true if value contains DateTime interface, else return false
'*************************************************
Function FW_IsDateTime(value As Dynamic) As Boolean
    Return FW_IsValid(value) And (GetInterface(value, "ifDateTime") <> invalid Or Type(value) = "roDateTime")
End Function

'*************************************************
' FW_IsValid - check if value initialized and not equal invalid
' @param value As Dynamic
' @return As Boolean - true if value initialized and not equal invalid, else return false
'*************************************************
Function FW_IsValid(value As Dynamic) As Boolean
    Return Type(value) <> "<uninitialized>" And value <> invalid
End Function

'*************************************************
' FW_ValidStr - return value if his contains String interface else return empty string
' @param value As Object
' @return As String - value if his contains String interface else return empty string
'*************************************************
Function FW_ValidStr(obj As Object) As String
    if obj <> invalid and GetInterface(obj, "ifString") <> invalid
        return obj
    else
        return ""
    endif
End Function

'*************************************************
' FW_AsString - convert input to String if this possible, else return empty string
' @param input As Dynamic
' @return As String - return converted string
'*************************************************
Function FW_AsString(input As Dynamic) As String
    If FW_IsValid(input) = False Then
        Return ""
    Else If FW_IsString(input) Then
        Return input
    Else If FW_IsInteger(input) or FW_IsLongInteger(input) or FW_IsBoolean(input)Then
        Return input.ToStr()
    Else If FW_IsFloat(input) or FW_IsDouble(input) Then
        Return Str(input).Trim()
    Else If FW_IsBoolean(input) Then
        If input Then
            Return "true"
        Else
            Return "false"
        End If
    Else If FW_IsSGNode(input) Then
        return input.subtype()
    Else If FW_IsArray(input) Then
        result = ""
        For each item in input
            result = result + FW_AsString(item) + ", "
        End For
        Return "[" + Left(result, Len(result) - 2) + "]"
    Else If FW_IsAssociativeArray(input) Then
        result = ""
        For each key in input
            result = result + key + " : " + FW_AsString(input[key]) + ", "
        End For
        Return "{ " + Left(result, Len(result) - 2) + " }"
    End If
    return ""
End Function

'*************************************************
' FW_AsInteger - convert input to Integer if this possible, else return 0
' @param input As Dynamic
' @return As Integer - return converted Integer
'*************************************************
Function FW_AsInteger(input As Dynamic) As Integer
    If FW_IsValid(input) = False Then
        Return 0
    Else If FW_IsString(input) Then
        Return input.ToInt()
    Else If FW_IsInteger(input) Then
        Return input
    Else If FW_IsFloat(input) or FW_IsDouble(input) or FW_IsLongInteger(input) Then
        Return Int(input)
    Else
        Return 0
    End If
End Function

'*************************************************
' FW_AsLongInteger - convert input to LongInteger if this possible, else return 0
' @param input As Dynamic
' @return As Integer - return converted LongInteger
'*************************************************
Function FW_AsLongInteger(input As Dynamic) As LongInteger
    If FW_IsValid(input) = False Then
        Return 0
    Else If FW_IsString(input) Then
        Return FW_AsInteger(input)
    Else If FW_IsLongInteger(input) or FW_IsFloat(input) or FW_IsDouble(input) or FW_IsInteger(input) Then
        Return input
    Else
        Return 0
    End If
End Function

'*************************************************
' FW_AsFloat - convert input to Float if this possible, else return 0.0
' @param input As Dynamic
' @return As Float - return converted Float
'*************************************************
Function FW_AsFloat(input As Dynamic) As Float
    If FW_IsValid(input) = False Then
        Return 0.0
    Else If FW_IsString(input) Then
        Return input.ToFloat()
    Else If FW_IsInteger(input) Then
        Return (input / 1)
    Else If FW_IsFloat(input) or FW_IsDouble(input) or FW_IsLongInteger(input) Then
        Return input
    Else
        Return 0.0
    End If
End Function

'*************************************************
' FW_AsDouble - convert input to Double if this possible, else return 0.0
' @param input As Dynamic
' @return As Float - return converted Double
'*************************************************
Function FW_AsDouble(input As Dynamic) As Double
    If FW_IsValid(input) = False Then
        Return 0.0
    Else If FW_IsString(input) Then
        Return FW_AsFloat(input)
    Else If FW_IsInteger(input) or FW_IsLongInteger(input) or FW_IsFloat(input) or FW_IsDouble(input) Then
        Return input
    Else
        Return 0.0
    End If
End Function

'*************************************************
' FW_AsBoolean - convert input to Boolean if this possible, else return False
' @param input As Dynamic
' @return As Boolean
'*************************************************
Function FW_AsBoolean(input As Dynamic) As Boolean
    If FW_IsValid(input) = False Then
        Return False
    Else If FW_IsString(input) Then
        Return LCase(input) = "true"
    Else If FW_IsInteger(input) Or FW_IsFloat(input) Then
        Return input <> 0
    Else If FW_IsBoolean(input) Then
        Return input
    Else
        Return False
    End If
End Function

'*************************************************
' FW_AsArray - if type of value equals array return value, else return array with one element [value]
' @param value As Object
' @return As Object - roArray
'*************************************************
Function FW_AsArray(value As Object) As Object
    If FW_IsValid(value)
        If Not FW_IsArray(value) Then
            Return [value]
        Else
            Return value
        End If
    End If
    Return []
End Function

'*************************************************
' FW_ValidAA - check if obj contains all keys
' @param obj As Object   - roAssociativeArray
' @param keys as Object  - roArray of keys(string) to check
' @param delim as String - key delimiter (default = ".")
' @return As Boolean - return true if type of obj equals AssociativeArray and obj contains all keys, else return false
'*************************************************
Function FW_ValidAA(obj As Object, keys as Object, delim = "." as String) as Boolean
    'All keys on level 0
    if not FW_IsAssociativeArray(obj) or not FW_IsNotEmptyString(delim) or not FW_isArray(keys) then
        return false
    end if
    for each key in Keys
        subKeys = key.split(delim)
        aa_check = obj
        'go down the hierarchy key.subkey.subsubkey...
        for each subkey in subKeys
            if FW_IsAssociativeArray(aa_check) and aa_check[subkey] <> invalid then
                aa_check = aa_check[subkey]
            else
                print "Key::"; key
                print "subkey::"; subkey
                'printAA(obj)
                return false

            end if
        end for

    end for
    return true
end Function

'*************************************************
' FW_GetSubElement - check if obj contains subElementTree element and return him
' @param element as Dynamic - roAssociativeArray
' @param subElementTree as Dynamic - String keys tree
' @param delim as String - key delimiter (default = ".")
' @return As Dynamic - if exist obj[subElementTree] value else invalid
'*************************************************
function FW_GetSubElement(element as Dynamic, subElementTree as Dynamic, delim = "." as String) as Dynamic
    if FW_IsValid(element) = false or FW_IsValid(subElementTree) = false then
        return invalid
    end if

    subElementTreeArray = []
    result = element

    if FW_IsNotEmptyString(subElementTree) and FW_IsNotEmptyString(delim) then
       subElementTreeArray = subElementTree.split(delim)
    else if FW_IsArray(subElementTree) then
       subElementTreeArray = subElementTree
    else
        result = invalid
    end if

    for each field in subElementTreeArray
        if FW_IsSGNode(result) then
            key = FW_AsString(field)
            if result.HasField(key) then
                result = result.GetField(key)
            else
                index = FW_AsInteger(field)
                if (index = 0 and key <> "0") or index < 0 or index >= result.GetChildCount() then
                    result = invalid
                    exit for
                end if
                result = result.GetChild(index)
            end if
        else if FW_IsAssociativeArray(result) then
            result = result.LookupCI(FW_AsString(field))        'use case-insensitive lookup for AAs
        else if FW_IsArray(result) then
            index = FW_AsInteger(field)
            if (index = 0 and FW_AsString(field) <> "0") or index < 0 or index >= result.Count() then     'index is not an integer or out of range?
                result = invalid
                exit for
            end if
            result = result[index]
        else
            result = invalid
            exit for
        end if
    end for

    return result
end function


' RALE_parseType - Parse type name to brs type
' @param {string} _type - type
' @return {string} - brs type
Function RALE_parseType(_type as String) as String
    _type =  LCase(_type)
    convertMap = {
        "rointeger" : "integer",
        "roint"     : "integer",
        "int"       : "integer",
        "num"       : "integer",
        "number"    : "integer",

        "rofloat" : "float",

        "rostring" : "string",
        "text"     : "string",
        "str"      : "string",

        "roboolean" : "bool",
        "boolean"   : "bool",

        "rosgnode" : "node",

        "roarray" : "array",
        "array"   : "array",
        "arr"     : "array",

        "object"             : "assocarray",
        "associativearray"   : "assocarray",
        "roassociativearray" : "assocarray"
    }
    if convertMap[_type] <> Invalid then return convertMap[_type]
    return _type
End function

' RALE_convertToType - Convert variable to type
' @param {dynamic} value - variable value
' @param {string} _type - type to which you want to convert
' @return {dynamic} - new variable value
Function RALE_convertToType(value as Dynamic, _type as String) as Dynamic
    _type = RALE_parseType(_type)

    convertMap = {
        "integer" : FW_AsInteger,
        "float" : FW_AsFloat,
        "bool" : FW_AsBoolean,
        "string" : FW_AsString,
        "array" : FW_AsArray,
    }

    if _type = "assocarray" and type(value) <> "roAssociativeArray" then
        value = CreateObject("roAssociativeArray")
    end if
    if _type = "array" and type(value) <> "roArray" then
        value = FW_AsString(value).split(",")
    end if
    if _type = "node" then
        value = CreateObject("roSGNode", FW_AsString(value))
    end if

    if convertMap[_type] <> Invalid then
        return convertMap[_type](value)
    end if
    return value
End function

' RALE_getNodeByItem - Returns node field or child by item data
' @param {dynamic} item - item data
' @param {dynamic} node - type to which you want to convert
' @return {dynamic} - node field or child
Function RALE_getNodeByItem(item as Dynamic, node as Dynamic) as Dynamic
    itemType = type(item)
    if itemType <> "roAssociativeArray" then return Invalid

    nodeType = type(node)
    if nodeType <> "roSGNode" and nodeType <> "roArray" and nodeType <> "roAssociativeArray" then
        return Invalid
    end if

    if nodeType = "roSGNode" and item.child <> Invalid then
        index = FW_AsInteger(item.child)
        if index = 0 and FW_AsString(item.child) <> "0" then return Invalid

        return node.getChild(index)
    else if item.field <> Invalid then
        key = item.field
        if nodeType = "roSGNode" then
            if node.hasField(key) then
                return node.getField(key)
            else
                return Invalid
            end if
        else
            key = item.field
            if nodeType = "roArray" then
                key = FW_AsInteger(key)
                if key = 0 and FW_AsString(item.field) <> "0" then return Invalid
            end if

            return node[key]
        end if
    else
        return Invalid
    end if
End function

' RALE_getNodeByPath - Returns node by path
' @param {object} root - root of nodes (main scene)
' @param {array} path - path to node (for example [{ child: 1 }, { field: "fieldId" }])
' @return {dynamic} - node or Invalid (if no node by this path)
Function RALE_getNodeByPath(root as Dynamic, path as Object) as Dynamic
    node = root

    if type(path) <> "roArray" then return Invalid

    for each item in path
        node = RALE_getNodeByItem(item, node)
        if node = Invalid then return Invalid
    end for

    return node
End function

' RALE_getNodeIndex - Returns node index
' @param {object} node - node
' @param {object} parent - node parent
' @return {integer} - node index
Function RALE_getNodeIndex(node, parent) as Integer
    for i = 0 to parent.getchildCount() - 1
        if parent.getChild(i).isSameNode(node) then return i
    end for
    return -1
End Function

' RALE_getNodePath - Returns node path
' @param {object} node - node
' @param {object} root - root
' @return {array} - node path
Function RALE_getNodePath(node, root) as Object
    path = []

    if node <> Invalid and root <> Invalid then
        parent = node.getParent()
        while parent <> Invalid
            index = RALE_getNodeIndex(node, parent)
            if index = -1 then exit while

            node = parent
            parent = node.getParent()

            path.unshift({ child: index })

            if root.isSameNode(node) then exit while
        end while
    end if
    return path
End Function

' RALE_getNodeListByPath - Returns node by path
' @param {object} root - root of nodes (main scene)
' @param {array} path - path to node (for example [{ child: 1 }, { field: "fieldId" }])
' @return {dynamic} - list of nodes (parent nodes and selected one) or Invalid (if no node by this path)
Function RALE_getNodeListByPath(root as Dynamic, path as Object) as Dynamic
    node = root
    nodeList = [node]

    if type(path) <> "roArray" then return Invalid

    for each item in path
        node = RALE_getNodeByItem(item, node)
        if node = Invalid then return Invalid
        nodeList.push(node)
    end for

    return nodeList
End function

' RALE_getNodeIndexByPath - Returns node index or id by path
' @param {array} path - path to node (for example [{ child: 1 }, { field: "fieldId" }])
' @return {dynamic} - node index or id or Invalid (if no node by this path)
Function RALE_getNodeIndexByPath(path) as Dynamic
    if type(path) <> "roArray" then return Invalid

    length = path.count()
    if length = 0 then return ""

    index = path[length - 1]

    if type(index) <> "roAssociativeArray" then return Invalid

    if index.child <> Invalid then
        index = index.child
    else if index.field <> Invalid then
        index = index.field
    else
        return Invalid
    end if

    return index
End function

' RALE_splitStringByLength - Splits string on parts and store in array
' @param {string} str - string which will be splitted
' @param {integer} length - max part langth
' @return {array} - splitted string
Function RALE_splitStringByLength(str, length) as Dynamic
    list = []
    strLength = str.len()
    currentPosition = 0

    while currentPosition < strLength
        list.push(str.mid(currentPosition, length))
        currentPosition = currentPosition + length
    end while

    return list
End function

' RALE_forEachNode - Goes through all the children and call the callback function
' @param {object} node - root node
' @param {object} options - options
' @param {function} callback - callback function that will be called for each node
Function RALE_forEachChild(node, options, callback, storage) as Dynamic
    nodeType = type(node)
    maxLevel = 50

    if FW_IsInteger(options.maxLevel) then
        maxLevel = options.maxLevel
    end if

    if nodeType = "roSGNode" then
        level = 0
        stateStack = []
        stateObj = {
            index : 0
            node : node
        }

        childCount = node.getchildcount()
        while true

            if childCount > stateObj.index then
                childIndex = stateObj.index
                childNode = node.getchild(childIndex)

                stateObj.index++

                if childNode <> invalid then
                    childCountTmp = childNode.getchildcount()

                    parentObj = stateObj
                    childObj = Invalid

                    if childCountTmp > 0 and level < maxLevel then
                        childCount = childCountTmp
                        stateStack.push(stateObj)
                        level++

                        stateObj = {
                            index : 0
                            node : childNode
                        }
                        childObj = stateObj

                        node = childNode
                    end if

                    result = callback(childNode, childIndex, parentObj, childObj, storage)

                    if not result then
                        exit while
                    end if
                end if
            else if level > 0 then
                stateObj = stateStack.pop()
                level--
                node = stateObj.node
                childCount = stateObj.node.getchildcount()
            else
                exit while
            end if
        end while
    else
        return false
    end if

    return true
End function

' RALE_forEachRegistryField - Goes through all the roRegistry and call the callback function for each field
' @param {function} callback - callback function that will be called for each field
Function RALE_forEachRegistryField(callback, storage) as Dynamic
    Registry = CreateObject("roRegistry")

    for each section in Registry.GetSectionList()
        RegistrySection = CreateObject("roRegistrySection", section)
        for each key in RegistrySection.GetKeyList()
            callback(RegistrySection.Read(key), key, section, storage)
        end for
    end for
End function

' RALE_forEachRegistrySection - Goes through all the roRegistry and call the callback function for each section
' @param {function} callback - callback function that will be called for each section
Function RALE_forEachRegistrySection(callback, storage) as Dynamic
    Registry = CreateObject("roRegistry")

    for each section in Registry.GetSectionList()
        callback(CreateObject("roRegistrySection", section), section, storage)
    end for
End function

Function RALE_DebugLog(message as String)
    callCommand("UIThread_log", {
        message: message,
        status: "debug"
    })
End Function

Function RALE_InfoLog(message as String)
    callCommand("UIThread_log", {
        message: message,
        status: "info"
    })
End Function

Function RALE_WarningLog(message as String)
    callCommand("UIThread_log", {
        message: message,
        status: "warning"
    })
End Function

Function RALE_ErrorLog(message as String)
    callCommand("UIThread_log", {
        message: message,
        status: "error"
    })
End Function
