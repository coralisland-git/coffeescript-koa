var DataAxis,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

DataAxis = (function() {
  function DataAxis(options) {
    this.addOptions = bind(this.addOptions, this);
    this.addStripLine = bind(this.addStripLine, this);
    this.setLabelFontColor = bind(this.setLabelFontColor, this);
    this.setLabelFontAngle = bind(this.setLabelFontAngle, this);
    this.setLabelFontSize = bind(this.setLabelFontSize, this);
    this.setPrefix = bind(this.setPrefix, this);
    this.setFormatString = bind(this.setFormatString, this);
    this.setRange = bind(this.setRange, this);
    this.setTitle = bind(this.setTitle, this);
    this.setFormatMoney = bind(this.setFormatMoney, this);
    this.data = {};
    if (options != null) {
      $.extend(this.data, options);
    }
    this.setLabelFontSize(12);
    this.setLabelFontAngle(0);
  }

  DataAxis.prototype.setFormatMoney = function() {
    return this.data.labelFormatter = (function(_this) {
      return function(e) {
        var num;
        num = e.value;
        if (num == null) {
          return "";
        }
        if (typeof num !== "number") {
          return num;
        }
        if (num < 10000) {
          return numeral(num).format('#,###');
        }
        if (num < 1000000) {
          return numeral(num / 1000).format('#,###') + " k";
        }
        return numeral(num / 1000000).format('#,###.[###]') + " m";
      };
    })(this);
  };

  DataAxis.prototype.setTitle = function(title) {
    if (title == null) {
      return delete this.data.title;
    } else {
      return this.data.title = title;
    }
  };

  DataAxis.prototype.setRange = function(minvalue, maxvalue) {
    this.data.minimum = minvalue;
    return this.data.maximum = maxvalue;
  };

  DataAxis.prototype.setFormatString = function(str) {
    return this.data.valueFormatString = str;
  };

  DataAxis.prototype.setPrefix = function(str) {
    return this.data.prefix = str;
  };

  DataAxis.prototype.setLabelFontSize = function(newSize) {
    this.data.labelFontFamily = "San Francisco Display,Arial,sans-serif";
    return this.data.labelFontSize = newSize;
  };

  DataAxis.prototype.setLabelFontAngle = function(newAngle) {
    return this.data.labelAngle = newAngle;
  };

  DataAxis.prototype.setLabelFontColor = function(newColor) {
    return this.data.labelFontColor = newColor;
  };

  DataAxis.prototype.addStripLine = function(startValue, endValue, options) {
    var stripLine;
    if (!this.data.stripLines) {
      this.data.stripLines = [];
    }
    stripLine = {
      startValue: startValue,
      endValue: endValue,
      color: "#2FD971",
      showOnTop: true,
      labelAlign: "near"
    };
    if (endValue === startValue) {
      stripLine.value = startValue;
      delete stripLine.endValue;
      delete stripLine.startValue;
    }
    $.extend(stripLine, options);
    this.data.stripLines.push(stripLine);
    return stripLine;
  };

  DataAxis.prototype.addOptions = function(options) {
    var key, value;
    for (key in options) {
      value = options[key];
      this.data[key] = value;
    }
    return options;
  };

  return DataAxis;

})();
var DataSeries,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

DataSeries = (function() {
  DataSeries.defaults = {
    indexLabelFontSize: 18,
    indexLabelPlacement: "outside",
    indexLabelFontColor: "#eeeeee",
    indexLabelFontFamily: "San Francisco Text,Verdana,sans-serif",
    colors: ['#007ACC', '#DF4A00', '#8618C1', '#E07600', '#F0C807', '#DF65B4', '#6F754B', '#2B56A8', '#6C13A0']
  };

  function DataSeries(options) {
    this.getDataPoints = bind(this.getDataPoints, this);
    this.getData = bind(this.getData, this);
    this.setSeriesType = bind(this.setSeriesType, this);
    this.addBubblePoint = bind(this.addBubblePoint, this);
    this.addPoint = bind(this.addPoint, this);
    this.addAggregatePoint = bind(this.addAggregatePoint, this);
    this.setIndexLabelThousands = bind(this.setIndexLabelThousands, this);
    this.addRangePoint = bind(this.addRangePoint, this);
    this.sortTimeseries = bind(this.sortTimeseries, this);
    this.setLegend = bind(this.setLegend, this);
    this.setColor = bind(this.setColor, this);
    this.setIndexThemeColor = bind(this.setIndexThemeColor, this);
    this.setFormatMoney = bind(this.setFormatMoney, this);
    this.data = {
      type: "scatter",
      legendText: "New DataSeries",
      showInLegend: false,
      dataPoints: [],
      pointCount: 0
    };
    if ((options != null) && typeof options === "string") {
      this.setLegend(options);
    } else if (options != null) {
      $.extend(this.data, options);
    }
    this.fieldName = 'label';
  }

  DataSeries.prototype.setFormatMoney = function() {
    return this.data.indexLabelFormatter = (function(_this) {
      return function(e) {
        var num;
        num = e.dataPoint.y;
        if (e.total != null) {
          num = e.total;
        }
        if (num == null) {
          return "";
        }
        if (typeof num !== "number") {
          return num;
        }
        if (num === 0) {
          return "";
        }
        if (num < 10000) {
          return numeral(num).format('#,###');
        }
        if (num < 1000000) {
          return numeral(num / 1000).format('#,###') + " k";
        }
        return numeral(num / 1000000).format('#,###.[###]') + " m";
      };
    })(this);
  };

  DataSeries.prototype.setIndexThemeColor = function(num) {
    while (num > DataSeries.defaults.colors.length) {
      num -= DataSeries.defaults.colors.length;
    }
    this.data.indexLabelFontSize = DataSeries.defaults.indexLabelFontSize;
    this.data.indexLabelPlacement = DataSeries.defaults.indexLabelPlacement;
    this.data.indexLabelFontColor = DataSeries.defaults.indexLabelFontColor;
    this.data.indexLabelFontFamily = DataSeries.defaults.indexLabelFontFamily;
    this.data.color = DataSeries.defaults.colors[num];
    return true;
  };

  DataSeries.prototype.setColor = function(newColor) {
    return this.data.color = newColor;
  };

  DataSeries.prototype.setLegend = function(newText) {
    this.data.legendText = newText;
    this.data.showInLegend = true;
    return true;
  };

  DataSeries.prototype.sortTimeseries = function() {
    return this.data.dataPoints = this.data.dataPoints.sort((function(_this) {
      return function(a, b) {
        var a1, b1;
        a1 = a.x || a.label;
        b1 = b.x || b.label;
        if (!a1) {
          console.log("Invalid point:", a);
          return -1;
        }
        if (!b1) {
          console.log("Invalid point b:", b);
          return 1;
        }
        if (a1.getTime() < b1.getTime()) {
          return -1;
        }
        return 1;
      };
    })(this));
  };

  DataSeries.prototype.addRangePoint = function(value, label) {
    var i, len, p, point, ref;
    this.data.type = "rangeColumn";
    this.data.pointCount++;
    ref = this.data.dataPoints;
    for (i = 0, len = ref.length; i < len; i++) {
      p = ref[i];
      if (p[this.fieldName].toString() === label.toString()) {
        if (!Array.isArray(p.y)) {
          p.y = [p.y];
        }
        p.y.push(value);
        p.y = p.y.sort();
        return true;
      }
    }
    this.data.type = "scatter";
    point = {
      y: [value, value]
    };
    point[this.fieldName] = label;
    return this.data.dataPoints.push(point);
  };

  DataSeries.prototype.setIndexLabelThousands = function() {
    this.data.indexLabel = "{y}";
    this.data.indexLabelFontColor = '#EBC641';
    this.data.indexLabelFontSize = 18;
    this.data.indexLabelFontStyle = 'bold';
    this.data.indexLabelFormatter = function(e) {
      return numeral(e.dataPoint.y).format("#,###") + " k";
    };
    return true;
  };

  DataSeries.prototype.addAggregatePoint = function(value, label) {
    var i, len, p, point, ref;
    ref = this.data.dataPoints;
    for (i = 0, len = ref.length; i < len; i++) {
      p = ref[i];
      if (p[this.fieldName].toString() === label.toString()) {
        p.y = (p.y || 0) + value;
        return true;
      }
    }
    point = {
      y: value
    };
    point[this.fieldName] = label;
    return this.data.dataPoints.push(point);
  };

  DataSeries.prototype.addPoint = function(x, y, legendText) {
    var point;
    point = {};
    point.y = y;
    point[this.fieldName] = x;
    if (legendText) {
      point.legendText = legendText;
    }
    this.data.dataPoints.push(point);
    return point;
  };

  DataSeries.prototype.addBubblePoint = function(x, y, z, name) {
    var point;
    point = {
      x: x,
      y: y,
      z: z
    };
    point[this.fieldName] = name;
    this.data.dataPoints.push(point);
    return point;
  };

  DataSeries.prototype.setSeriesType = function(newType) {
    this.data.type = newType;
    return true;
  };

  DataSeries.prototype.getData = function() {
    return this.data;
  };

  DataSeries.prototype.getDataPoints = function() {
    return this.data.dataPoints;
  };

  return DataSeries;

})();
var CodeEditor;

CodeEditor = (function() {
  var _editor, _histories, _options, languageMode;

  _editor = null;

  languageMode = "mysql";

  _options = {};

  _histories = [];

  function CodeEditor(elementHolder, languageMode1) {
    this.elementHolder = elementHolder;
    this.languageMode = languageMode1 != null ? languageMode1 : "mysql";
    if (!this.elementHolder.length) {
      throw new Error("The specified element " + this.elementHolder.selector + " not found");
    }
    if (typeof ace === "undefined") {
      throw new Error("Ace editor is not loaded this component depends on ace, so ace editor must be loaded first");
    }
    ace.require("ace/ext/language_tools");
    this._editor = ace.edit(this.elementHolder.attr('id'));
    this._editor.session.setUseWrapMode(true);
    this._editor.session.setWrapLimitRange(120, 120);
    this.setMode(this.languageMode);
    this.gid = GlobalValueManager.NextGlobalID();
    this._histories = [];
    this;
  }

  CodeEditor.prototype.setMode = function(languageMode1) {
    this.languageMode = languageMode1;
    this._editor.session.setMode("ace/mode/" + this.languageMode);
    return this;
  };

  CodeEditor.prototype.setTheme = function(themeName) {
    this._editor.setTheme("ace/theme/" + themeName);
    return this;
  };

  CodeEditor.prototype.setOptions = function(_options1) {
    this._options = _options1;
    console.log(this._options);
    this._editor.setOptions(this._options);
    return this;
  };

  CodeEditor.prototype.popupMode = function(popupMode) {
    this.popupMode = popupMode != null ? popupMode : true;
    this.elementHolder.parents('.scrollcontent').on("resize", (function(_this) {
      return function(e) {
        return _this._editor.resize();
      };
    })(this));
    this.setOptions({
      tooltipFollowsMouse: false
    });
    this._editor.addEventListener("guttermousemove", (function(_this) {
      return function(e) {
        return setTimeout(function() {
          return _this.elementHolder.find(".ace_tooltip").offset({
            left: 0,
            top: 0
          });
        }, 0);
      };
    })(this));
    return this;
  };

  CodeEditor.prototype.getInstance = function() {
    return this._editor;
  };

  CodeEditor.prototype.getContent = function() {
    return this._editor.session.getValue();
  };

  CodeEditor.prototype.setContent = function(content) {
    this._editor.session.setValue(content);
    return this;
  };

  CodeEditor.prototype.insert = function(content) {
    this._editor.insert(content);
    return this;
  };

  CodeEditor.prototype.onChange = function(changeCallback) {
    this.changeCallback = changeCallback;
    return this._editor.getSession().on('change', (function(_this) {
      return function(e) {
        return _this.changeCallback(_this.getContent(), _this._editor);
      };
    })(this));
  };

  CodeEditor.prototype.addToHistory = function(code) {
    var _index;
    if (this._histories.indexOf(code) === -1) {
      this._histories.unshift(code);
    } else {
      _index = this._histories.indexOf(code);
      this.internalMoveHistoryItem(_index, 0);
    }
    return this.saveHistory();
  };

  CodeEditor.prototype.saveHistory = function() {
    _histories = JSON.stringify(this._histories.slice(0, 100));
    return localStorage.setItem("_histories_" + this.gid, _histories);
  };

  CodeEditor.prototype.getHistories = function() {
    _histories = localStorage.getItem("_histories_" + this.gid);
    if (_histories) {
      return JSON.parse(_histories);
    }
    return false;
  };

  CodeEditor.prototype.internalMoveHistoryItem = function(oldIndex, newIndex) {
    var _temp;
    if (newIndex >= this._histories.length) {
      _temp = newIndex - this._histories.length;
      while ((_temp--) + 1) {
        this._histories.push(void 0);
      }
    }
    this._histories.splice(newIndex, 0, this._histories.splice(oldIndex, 1)[0]);
    return this;
  };

  CodeEditor.prototype.renderHistories = function(holder, changedCallback) {
    var select;
    if (holder == null) {
      holder = null;
    }
    if (changedCallback == null) {
      changedCallback = null;
    }
    if (!holder) {
      throw new Error("please provide element to render select box");
    }
    select = $("<select />");
    select.attr('id', this.gid + "_histories").addClass("form-control");
    _options = this.internalGetOptionsForSelect();
    select.append(_options);
    select.on("change", function() {
      if (changedCallback) {
        return changedCallback(select.val(), select);
      }
    });
    return holder.html(select);
  };

  CodeEditor.prototype.internalGetOptionsForSelect = function() {
    _options = ["<option value=''>Recent List</option>"];
    this.getHistories().forEach((function(_this) {
      return function(item) {
        return _options.push($("<option value='" + item + "'>" + item + "</option>"));
      };
    })(this));
    return _options;
  };

  CodeEditor.prototype.refreshHistories = function() {
    var select;
    select = $("select#" + this.gid + "_histories");
    _options = this.internalGetOptionsForSelect();
    select.find("option").remove();
    return select.append(_options);
  };

  return CodeEditor;

})();
var DataFormatter, root,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.DataFormatter = DataFormatter = (function() {
  DataFormatter.prototype.formats = {};

  DataFormatter.getNumber = function(data) {
    var m, result;
    if (data == null) {
      return 0;
    }
    if (typeof data === "number") {
      return data;
    }
    if (m = data.toString().match(/(\d+)\s*%/)) {
      console.log("M1=", m[1]);
      return parseFloat(m[1]) / 100.0;
    }
    result = data.toString().replace(/[^0-9\.\-]/g, "");
    result = parseFloat(result);
    if (isNaN(result)) {
      return 0;
    }
    return result;
  };

  DataFormatter.getMoment = function(data) {
    var e;
    try {
      if (data == null) {
        return null;
      }
      if ((data != null) && (data._isAMomentObject != null) && data._isAMomentObject) {
        return data;
      }
      if (typeof data === "object" && (data.getTime != null)) {
        return moment(data);
      }
      if (data.match(/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/)) {
        return moment(data, "YYYY-MM-DD HH:mm:ss");
      }
      if (data.match(/\d\d\d\d-\d\d-\d\d/)) {
        return moment(data, "YYYY-MM-DD");
      }
      if (data.match(/\d\d\d\d\.\d\d\.\d\d \d\d:\d\d:\d\d/)) {
        return moment(data, "YYYY-MM-DD HH:mm:ss");
      }
      if (data.match(/\d\d\d\d\.\d\d\.\d\d/)) {
        return moment(data, "YYYY-MM-DD");
      }
      if (data.match(/\d\d-\d\d-\d\d\d\d \d\d:\d\d:\d\d/)) {
        return moment(data, "MM-DD-YYYY HH:mm:ss");
      }
      if (data.match(/\d\d-\d\d-\d\d\d\d/)) {
        return moment(data, "MM-DD-YYYY");
      }
      if (data.match(/\d\d\/\d\d\/\d\d\d\d \d\d:\d\d:\d\d/)) {
        return moment(data, "MM/DD/YYYY HH:mm:ss");
      }
      if (data.match(/\d\d\/\d\d\/\d\d\d\d/)) {
        return moment(data, "MM/DD/YYYY");
      }
      if (typeof data === "object" && (data['$date'] != null)) {
        return moment(new Date(data['$date']));
      }
    } catch (error) {
      e = error;
      console.log("Unable to get date from [", data, "]");
    }
    return null;
  };

  DataFormatter.prototype.register = function(formattingClass) {
    return this.formats[formattingClass.name] = formattingClass;
  };

  DataFormatter.prototype.getFormatter = function(dataType) {
    if (!this.formats[dataType]) {
      console.log("Registered types:", this.formats);
      throw new Error("Invalid type: " + dataType);
    }
    return this.formats[dataType];
  };

  DataFormatter.prototype.formatData = function(dataType, data, options, path) {
    var value;
    if (this.formats[dataType] == null) {
      console.log("Registered types:", this.formats);
      return "Invalid type [" + dataType + "]";
    }
    return value = this.formats[dataType].format(data, options, path);
  };

  DataFormatter.prototype.unformatData = function(dataType, data, options, path) {
    var value;
    if (this.formats[dataType] == null) {
      return "Invalid type [" + dataType + "]";
    }
    return value = this.formats[dataType].unformat(data, options, path);
  };

  function DataFormatter() {
    this.unformatData = bind(this.unformatData, this);
    this.formatData = bind(this.formatData, this);
    this.getFormatter = bind(this.getFormatter, this);
    this.register = bind(this.register, this);
  }

  return DataFormatter;

})();
var DataMapEngine, DataMapMemoryCollection, checkForNumber, reDate2,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

reDate2 = /[0-9\-]+T[0-9\:\.]+Z$/;

checkForNumber = /^[1-9\-][\d\-\.]{0,11}$/;

DataMapMemoryCollection = (function() {
  function DataMapMemoryCollection(name1, index) {
    this.name = name1;
    this.index = index;
    this.eraseCollection = bind(this.eraseCollection, this);
    this.getDocumentKey = bind(this.getDocumentKey, this);
    this.remove = bind(this.remove, this);
    this.upsert = bind(this.upsert, this);
    this.findFastRow = bind(this.findFastRow, this);
    this.findFast = bind(this.findFast, this);
    this.setFast = bind(this.setFast, this);
    this.find = bind(this.find, this);
    this.findAll = bind(this.findAll, this);
    this["export"] = bind(this["export"], this);
    this.data = {};
    this.count = 0;
  }

  DataMapMemoryCollection.prototype["export"] = function() {
    return this.data;
  };

  DataMapMemoryCollection.prototype.findAll = function(filterFunction) {
    var allResults, key, obj, ref, result;
    allResults = [];
    ref = this.data;
    for (key in ref) {
      obj = ref[key];
      if (filterFunction != null) {
        result = filterFunction(obj);
      } else {
        result = true;
      }
      if (result) {
        allResults.push(obj);
      }
    }
    return allResults;
  };

  DataMapMemoryCollection.prototype.find = function(condition) {
    var allResult, found, i, key, o, obj, ref;
    if ((this.index == null) && (condition != null) && (condition.id != null) && Object.keys(condition).length === 1) {
      if (this.data[condition.id] == null) {
        return null;
      }
      return this.data[condition.id];
    } else {
      allResult = [];
      ref = this.data;
      for (key in ref) {
        obj = ref[key];
        found = false;
        for (i in condition) {
          o = condition[i];
          if (obj[i] !== o) {
            found = false;
          }
        }
        if (found) {
          allResult.push(o);
        }
      }
      return allResult;
    }
  };

  DataMapMemoryCollection.prototype.setFast = function(idValue, subKey, newValue) {
    if ((idValue != null) && (this.data[idValue] != null)) {
      this.data[idValue][subKey] = newValue;
    }
  };

  DataMapMemoryCollection.prototype.findFast = function(idValue, subKey) {
    if ((idValue != null) && (this.data[idValue] != null)) {
      return this.data[idValue][subKey];
    } else {
      return null;
    }
  };

  DataMapMemoryCollection.prototype.findFastRow = function(idValue) {
    if ((idValue != null) && (this.data[idValue] != null)) {
      return this.data[idValue];
    } else {
      return null;
    }
  };

  DataMapMemoryCollection.prototype.upsert = function(doc) {
    var isKeyNew, strKey;
    strKey = this.getDocumentKey(doc);
    isKeyNew = this.data[strKey] != null;
    this.data[strKey] = doc;
    if (isKeyNew) {
      this.count++;
    }
    return this.data[strKey];
  };

  DataMapMemoryCollection.prototype.remove = function(condition) {
    var allResults, i, obj, strKey;
    allResults = this.find(condition);
    if (allResults == null) {
      return false;
    }
    if ((allResults != null) && (allResults[0] != null)) {
      for (i in allResults) {
        obj = allResults[i];
        strKey = this.getDocumentKey[obj];
        delete this.data[strKey];
      }
    } else {
      delete this.data[this.getDocumentKey(allResults)];
    }
    return true;
  };

  DataMapMemoryCollection.prototype.getDocumentKey = function(doc) {
    var j, keyName, len, ref, strKey;
    if (this.index == null) {
      return doc.id;
    }
    strKey = "";
    ref = this.index;
    for (j = 0, len = ref.length; j < len; j++) {
      keyName = ref[j];
      if (doc[keyName] == null) {
        doc[keyName] = this.count++;
      }
      strKey += doc[keyName] + "-";
    }
    return strKey;
  };

  DataMapMemoryCollection.prototype.eraseCollection = function() {
    this.data = {};
    this.count = 0;
    return true;
  };

  return DataMapMemoryCollection;

})();

DataMapEngine = (function() {
  function DataMapEngine(dataSetName) {
    this.dataSetName = dataSetName;
    this.getConditionValue = bind(this.getConditionValue, this);
    this.parsePath = bind(this.parsePath, this);
    this.internalGetCollection = bind(this.internalGetCollection, this);
    this.setDataCallback = bind(this.setDataCallback, this);
    this.set = bind(this.set, this);
    this.setFastDocument = bind(this.setFastDocument, this);
    this.deepDiff = bind(this.deepDiff, this);
    this.get = bind(this.get, this);
    this.getFastRow = bind(this.getFastRow, this);
    this.setFast = bind(this.setFast, this);
    this.getFast = bind(this.getFast, this);
    this.find = bind(this.find, this);
    this["delete"] = bind(this["delete"], this);
    this["export"] = bind(this["export"], this);
    this.eraseCollection = bind(this.eraseCollection, this);
    this.off = bind(this.off, this);
    this.on = bind(this.on, this);
    if (this.dataSetName == null) {
      this.dataSetName = "globalds";
    }
    this.emitter = new EvEmitter();
    this.memData = {};
  }

  DataMapEngine.prototype.on = function(eventName, callbackFunction) {
    return this.emitter.on(eventName, callbackFunction);
  };

  DataMapEngine.prototype.off = function(eventName, callbackFunction) {
    return this.emitter.off(eventName, callbackFunction);
  };

  DataMapEngine.prototype.eraseCollection = function(collectionName) {
    return this.memData[collectionName] = new DataMapMemoryCollection(collectionName);
  };

  DataMapEngine.prototype["export"] = function(collectionName) {
    var c;
    c = this.internalGetCollection(collectionName);
    return c["export"]();
  };

  DataMapEngine.prototype["delete"] = function(pathText) {
    var c, path;
    path = this.parsePath(pathText);
    c = this.internalGetCollection(path.collection);
    return c.remove(path.condition);
  };

  DataMapEngine.prototype.find = function(collectionName, filterFunction) {
    var c;
    c = this.internalGetCollection(collectionName);
    return c.findAll(filterFunction);
  };

  DataMapEngine.prototype.getFast = function(collectionName, keyValue, subPath) {
    var c;
    if (collectionName == null) {
      throw new Error("Missing collection name");
    }
    if (typeof keyValue === "string" && checkForNumber.test(keyValue)) {
      keyValue = parseFloat(keyValue);
    }
    c = this.internalGetCollection(collectionName);
    return c.findFast(keyValue, subPath);
  };

  DataMapEngine.prototype.setFast = function(collectionName, keyValue, subPath, newValue) {
    var c;
    if (collectionName == null) {
      throw new Error("Missing collection name");
    }
    if (typeof keyValue === "string" && checkForNumber.test(keyValue)) {
      keyValue = parseFloat(keyValue);
    }
    c = this.internalGetCollection(collectionName);
    return c.setFast(keyValue, subPath, newValue);
  };

  DataMapEngine.prototype.getFastRow = function(collectionName, keyValue) {
    var c;
    if (collectionName == null) {
      throw new Error("Missing collection name");
    }
    if (typeof keyValue === "string" && checkForNumber.test(keyValue)) {
      keyValue = parseFloat(keyValue);
    }
    c = this.internalGetCollection(collectionName);
    return c.findFastRow(keyValue, "/");
  };

  DataMapEngine.prototype.get = function(pathText, insertIfNeeded) {
    var basePointer, c, doc, insertedDoc, j, len, name, path, ref;
    path = this.parsePath(pathText);
    c = this.internalGetCollection(path.collection);
    doc = c.find(path.condition);
    if ((insertIfNeeded != null) && (doc == null)) {
      doc = $.extend(true, {}, path.condition);
      insertedDoc = c.upsert(doc);
    }
    if ((path.subPath != null) && path.subPath.length > 0 && (doc != null)) {
      basePointer = doc;
      ref = path.subPath;
      for (j = 0, len = ref.length; j < len; j++) {
        name = ref[j];
        if (basePointer[name] == null) {
          basePointer[name] = {};
        }
        basePointer = basePointer[name];
      }
      return basePointer;
    }
    return doc;
  };

  DataMapEngine.prototype.deepDiff = function(src, target, basePath) {
    var d, diffs, i, j, len, o, results;
    if (src == null) {
      src = {};
    }
    diffs = [];
    for (i in target) {
      o = target[i];
      if (typeof o === "Object") {
        results = this.deepDiff(src[i], o, basePath + "/" + i);
        for (j = 0, len = results.length; j < len; j++) {
          d = results[j];
          diffs.push(d);
        }
      } else if (src[i] == null) {
        diffs.push({
          path: basePath + ("/" + i),
          kind: "N",
          rhs: o
        });
      } else if (src[i] !== o) {
        diffs.push({
          path: basePath + ("/" + i),
          kind: "E",
          lhs: src[i],
          rhs: o
        });
      }
    }
    for (i in src) {
      o = src[i];
      if (target[i] == null) {
        diffs.push({
          path: basePath + ("/" + i),
          kind: "D",
          lhs: o
        });
      }
    }
    return diffs;
  };

  DataMapEngine.prototype.setFastDocument = function(tableName, keyValue, newData) {
    var c;
    c = this.internalGetCollection(tableName);
    if (keyValue != null) {
      newData.id = keyValue;
    }
    c.upsert(newData);
    return true;
  };

  DataMapEngine.prototype.set = function(pathText, newData) {
    var basePointer, c, d, diffs, doc, insertedDoc, j, k, len, len1, name, origDoc, path, ref;
    path = this.parsePath(pathText);
    doc = this.get({
      condition: path.condition,
      collection: path.collection
    }, true);
    if (Object.keys(doc).length < 2) {
      c = this.internalGetCollection(path.collection);
      newData.id = doc.id;
      insertedDoc = c.upsert(newData);
      return insertedDoc;
    }
    origDoc = $.extend(true, {}, doc);
    basePointer = origDoc;
    if ((path.subPath != null) && path.subPath.length > 0 && (doc != null)) {
      ref = path.subPath;
      for (j = 0, len = ref.length; j < len; j++) {
        name = ref[j];
        if (basePointer[name] == null) {
          basePointer[name] = {};
        }
        basePointer = basePointer[name];
      }
    }
    DataMapEngine.deepMergeObject(basePointer, newData);
    c = this.internalGetCollection(path.collection);
    insertedDoc = c.upsert(origDoc);
    diffs = this.deepDiff(doc, origDoc, "/" + path.collection + "/" + path.condition.id);
    for (k = 0, len1 = diffs.length; k < len1; k++) {
      d = diffs[k];
      this.emitter.emitEvent('change', [d]);
    }
    return insertedDoc;
  };

  DataMapEngine.prototype.setDataCallback = function(tableName, methodName, callback) {
    var collection;
    collection = this.internalGetCollection(tableName);
    return collection[methodName] = callback;
  };

  DataMapEngine.prototype.internalGetCollection = function(tableName, indexList) {
    if (this.memData[tableName] == null) {
      this.memData[tableName] = new DataMapMemoryCollection(tableName, indexList);
    }
    return this.memData[tableName];
  };

  DataMapEngine.prototype.parsePath = function(path) {
    var keyParts, parts, result;
    if ((path != null) && (path.collection != null)) {
      return path;
    }
    result = {
      collection: "unknown",
      condition: {},
      subPath: null
    };
    path = path.replace("//", "/");
    parts = path.split('/');
    if (path.charAt(0) === '/') {
      parts.shift();
    }
    if ((parts == null) || !parts.length || parts.length < 2) {
      console.log("Error parsing path [" + path + "]");
      return result;
    }
    result.collection = parts.shift();
    keyParts = parts.shift().split(':');
    if ((keyParts[0] != null) && (keyParts[1] != null)) {
      result.condition[keyParts[0]] = this.getConditionValue(keyParts[1]);
    } else {
      result.condition["id"] = this.getConditionValue(keyParts[0]);
    }
    if (parts.length > 0) {
      if (parts[parts.length - 1].length === 0) {
        parts.pop();
      }
      result.subPath = parts;
    } else {
      result.subPath = [];
    }
    return result;
  };

  DataMapEngine.prototype.getConditionValue = function(value) {
    if (typeof value === "string" && checkForNumber.test(value)) {
      return parseFloat(value);
    }
    return value;
  };

  DataMapEngine.deepMergeObject = function(objTarget, objSrc, addAttributes, deleteAttributes, counter) {
    var flagFound, i, j, len, o, x, y;
    if (counter > 5) {
      return objTarget;
    }
    if (objTarget == null) {
      return null;
    }
    if (objSrc == null) {
      return null;
    }
    if (counter == null) {
      counter = 1;
    }
    flagFound = false;
    for (i in objSrc) {
      o = objSrc[i];
      if (o === null) {
        objTarget[i] = null;
      } else if (o instanceof Date) {
        objTarget[i] = new Date(o.getTime());
        flagFound = true;
      } else if (typeof o !== 'object') {
        objTarget[i] = o;
        flagFound = true;
      } else {
        if (!objTarget[i]) {
          objTarget[i] = {};
        }
        DataMapEngine.deepMergeObject(objTarget[i], o, addAttributes, deleteAttributes, counter + 1);
      }
      if (flagFound && (addAttributes != null)) {
        for (x in addAttributes) {
          y = addAttributes[x];
          objTarget[x] = y;
        }
      }
      if (flagFound && (deleteAttributes != null)) {
        for (j = 0, len = deleteAttributes.length; j < len; j++) {
          x = deleteAttributes[j];
          delete objTarget[x];
        }
      }
    }
    return objTarget;
  };

  return DataMapEngine;

})();
var DataMap, globalOpenEditor, root,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

globalOpenEditor = function(e) {
  var data, path;
  data = WidgetTag.getDataFromEvent(e);
  path = data.path;
  DataMap.getDataMap().editValue(path, e.target);
  return false;
};

root = typeof exports !== "undefined" && exports !== null ? exports : this;

DataMap = (function() {
  function DataMap(dataSetName) {
    this.dataSetName = dataSetName;
    this.setDataTypesFromSingleObject = bind(this.setDataTypesFromSingleObject, this);
    this.updatePathValueEvent = bind(this.updatePathValueEvent, this);
    this.updateScreenPathValue = bind(this.updateScreenPathValue, this);
    this.editValue = bind(this.editValue, this);
    this.data = {};
    this.types = {};
    this.onSave = {};
    this.objStore = {};
    this.cachedFormat = {};
    this.engine = new DataMapEngine();
    this.engine.on("change", (function(_this) {
      return function(diff, a, b) {
        if (diff.kind === "E") {
          return _this.updateScreenPathValue(diff.path, diff.lhs, true);
        }
      };
    })(this));
    GlobalClassTools.addEventManager(this);
  }

  DataMap.getDataMap = function() {
    if (!root.globalDataMap) {
      root.globalDataMap = new DataMap();
    }
    return root.globalDataMap;
  };

  DataMap.prototype.editValue = function(path, el) {
    var existingValue, fieldName, formatter, keyValue, parts, tableName;
    parts = path.split('/');
    tableName = parts[1];
    keyValue = parts[2];
    fieldName = parts[3];
    existingValue = this.engine.getFast(tableName, keyValue, fieldName);
    formatter = this.types[tableName].col[fieldName].getFormatter();
    formatter.options = this.types[tableName].col[fieldName].getOptions();
    formatter.editData(el, existingValue, path, this.updatePathValueEvent);
    return true;
  };

  DataMap.prototype.updateScreenPathValue = function(path, newValue, didDataChange) {
    if ((typeof globalKeyboardEvents !== "undefined" && globalKeyboardEvents !== null) && didDataChange) {
      globalKeyboardEvents.emitEvent("change", [path, newValue]);
    }
    return true;
  };

  DataMap.prototype.updatePathValueEvent = function(path, newValue) {
    var col, dm, existingValue, fieldName, j, keyValue, len, parts, ref, tableName;
    parts = path.split('/');
    tableName = parts[1];
    keyValue = parts[2];
    fieldName = parts[3];
    dm = DataMap.getDataMap();
    ref = DataMap.getColumnsFromTable(tableName);
    for (j = 0, len = ref.length; j < len; j++) {
      col = ref[j];
      delete dm.cachedFormat["/" + tableName + "/" + keyValue + "/" + (col.getSource())];
    }
    existingValue = this.engine.getFast(tableName, keyValue, fieldName);
    if (typeof existingValue === 'boolean' && existingValue === Boolean(newValue)) {
      return true;
    }
    if (existingValue === newValue) {
      return true;
    }
    dm.engine.setFast(tableName, keyValue, fieldName, newValue);
    this.updateScreenPathValue(path, newValue, true);
    if (this.onSave[tableName] != null) {
      this.onSave[tableName](keyValue, fieldName, existingValue, newValue);
    }
    return true;
  };

  DataMap.setSaveCallback = function(tableName, callbackFunction) {
    var dm;
    dm = DataMap.getDataMap();
    dm.onSave[tableName] = callbackFunction;
    return true;
  };

  DataMap.importDataTypes = function(tableName, savedConfig) {
    var dm, obj, sourceName;
    dm = DataMap.getDataMap();
    dm.types[tableName] = new DataTypeCollection(tableName);
    for (sourceName in savedConfig) {
      obj = savedConfig[sourceName];
      if (sourceName === "_lastModified") {
        continue;
      }
      if (typeof obj !== "object") {
        continue;
      }
      dm.types[tableName].configureColumns([obj], true);
    }
    return true;
  };

  DataMap.setDataTypes = function(tableName, columns) {
    var dm;
    dm = DataMap.getDataMap();
    if (dm.types[tableName] == null) {
      dm.types[tableName] = new DataTypeCollection(tableName);
    }
    dm.types[tableName].configureColumns(columns);
    return true;
  };

  DataMap.removeTableData = function(tableName) {
    var dm;
    dm = DataMap.getDataMap();
    dm.engine.eraseCollection(tableName);
    dm.cachedFormat = {};
    return true;
  };

  DataMap.removeTable = function(tableName) {
    var dm;
    dm = DataMap.getDataMap();
    dm.engine.eraseCollection(tableName);
    delete dm.types[tableName];
    dm.cachedFormat = {};
    return true;
  };

  DataMap.addColumn = function(tableName, options) {
    var config, dm, saveText;
    config = {
      name: "New Column",
      source: "newcol",
      visible: true,
      hideable: false,
      editable: false,
      sortable: true,
      required: false,
      align: "left",
      type: "text",
      width: null,
      tooltip: "",
      render: null,
      calculation: false
    };
    $.extend(config, options);
    DataMap.setDataTypes(tableName, [config]);
    dm = DataMap.getDataMap();
    saveText = dm.types[tableName].toSave();
    dm.emitEvent("table_change", [tableName, saveText]);
    return dm.types[tableName].col[config.source];
  };

  DataMap.setDataTypesFromObject = function(tableName, objects) {
    var dm, i, o, updated;
    dm = DataMap.getDataMap();
    dm.types[tableName] = new DataTypeCollection(tableName);
    updated = false;
    for (i in objects) {
      o = objects[i];
      if (dm.setDataTypesFromSingleObject(tableName, o)) {
        updated = true;
      }
    }
    if (updated) {
      dm.cachedFormat = {};
    }
    return updated;
  };

  DataMap.prototype.setDataTypesFromSingleObject = function(tableName, newData) {
    var colName, config, found, keyName, updated, value;
    if (this.types[tableName] == null) {
      this.types[tableName] = new DataTypeCollection(tableName);
    }
    updated = false;
    for (keyName in newData) {
      value = newData[keyName];
      if (keyName === "_id") {
        continue;
      }
      if (keyName === "loc") {
        continue;
      }
      if (keyName === "id") {
        continue;
      }
      if (keyName.charAt(0) === '_') {
        continue;
      }
      if (keyName === "hash") {
        continue;
      }
      found = this.types[tableName].getColumn(keyName);
      if (found == null) {
        colName = keyName.replace(/([a-z])([A-Z])/g, "$1 $2");
        colName = colName.replace(/_/g, " ");
        colName = colName.ucwords();
        config = {
          name: colName,
          source: keyName
        };
        updated = true;
        DataMap.addColumn(tableName, config);
      } else {
        found.deduceColumnType(value);
      }
    }
    return updated;
  };

  DataMap.getColumnsFromTable = function(tableName, reduceFunction) {
    var col, columns, dm, keepColumn, ref, source;
    dm = DataMap.getDataMap();
    columns = [];
    if (!dm.types[tableName]) {
      return columns;
    }
    ref = dm.types[tableName].col;
    for (source in ref) {
      col = ref[source];
      keepColumn = true;
      if (reduceFunction != null) {
        keepColumn = reduceFunction(col);
      }
      if (source.charAt(0) === "_") {
        keepColumn = false;
      }
      if (keepColumn) {
        columns.push(col);
      }
    }
    return columns;
  };

  DataMap.importDataFromObjects = function(tableName, objects) {
    var dm, i, o;
    dm = DataMap.getDataMap();
    for (i in objects) {
      o = objects[i];
      DataMap.addDataUpdateTable(tableName, i, o);
    }
    return true;
  };

  DataMap.setDataCallback = function(tableName, methodName, callback) {
    return DataMap.getDataMap().engine.setDataCallback(tableName, methodName, callback);
  };

  DataMap.exportTable = function(tableName) {
    return DataMap.getDataMap().engine["export"](tableName);
  };

  DataMap.getValuesFromTable = function(tableName, reduceFunction) {
    return DataMap.getDataMap().engine.find(tableName, reduceFunction);
  };

  DataMap.addData = function(tableName, keyValue, newData) {
    var dm, doc, path, value, varName;
    path = "/" + tableName + "/" + keyValue;
    dm = DataMap.getDataMap();
    doc = dm.engine.set(path, newData);
    for (varName in newData) {
      value = newData[varName];
      delete dm.cachedFormat["/" + tableName + "/" + keyValue + "/" + varName];
    }
    dm.emitEvent("new_data", [tableName, keyValue]);
    return doc;
  };

  DataMap.changeColumnAttribute = function(tableName, sourceName, field, newValue, ignoreEvents) {
    var col, dm;
    dm = DataMap.getDataMap();
    if (dm.types[tableName] == null) {
      return false;
    }
    col = dm.types[tableName].getColumn(sourceName);
    if (col == null) {
      return false;
    }
    dm.cachedFormat = {};
    if (field === "render") {
      new ErrorMessageBox("Field 'render' is no longer used, see renderCode, change " + tableName + ", source=" + sourceName + ", field=" + field + " new=" + newValue);
      return;
    }
    col.changeColumn(field, newValue);
    if ((ignoreEvents != null) && ignoreEvents === true || (typeof globalTableEvents === "undefined" || globalTableEvents === null)) {
      return true;
    }
    globalTableEvents.emitEvent("table_change", [tableName, sourceName, field, newValue]);
    return true;
  };

  DataMap.addDataUpdateTable = function(tableName, keyValue, newData) {
    var dm, doc, path, updated, value, varName;
    path = "/" + tableName + "/" + keyValue;
    doc = DataMap.getDataMap().engine.setFastDocument(tableName, keyValue, newData);
    dm = DataMap.getDataMap();
    if (dm.types[tableName] == null) {
      dm.types[tableName] = new DataTypeCollection(tableName);
    }
    updated = dm.setDataTypesFromSingleObject(tableName, newData);
    for (varName in newData) {
      value = newData[varName];
      delete dm.cachedFormat["/" + tableName + "/" + keyValue + "/" + varName];
    }
    if (dm.types[tableName].evWaiting != null) {
      clearTimeout(dm.types[tableName].evWaiting);
    }
    dm.types[tableName].evWaiting = setTimeout(function() {
      var ev;
      ev = new CustomEvent("new_data", {
        detail: {
          tablename: tableName,
          id: keyValue
        }
      });
      window.dispatchEvent(ev);
      return delete dm.types[tableName].evWaiting;
    }, 10);
    return doc;
  };

  DataMap.deleteDataByKey = function(tableName, keyValue) {
    var dm;
    dm = DataMap.getDataMap();
    return dm.engine["delete"]("/" + tableName + "/" + keyValue);
  };

  DataMap.getDataForKey = function(tableName, keyValue) {
    var dm;
    dm = DataMap.getDataMap();
    return dm.engine.getFastRow(tableName, keyValue);
  };

  DataMap.deleteDataForkey = function(tableName, keyValue) {
    return console.log("TODO: Not Implemented");
  };

  DataMap.getDataField = function(tableName, keyValue, fieldName) {
    var dm;
    dm = DataMap.getDataMap();
    return dm.engine.getFast(tableName, keyValue, fieldName);
  };

  DataMap.getDataFieldFormatted = function(tableName, keyValue, fieldName) {
    var currentValue, dm, path, ref, rowData;
    path = "/" + tableName + "/" + keyValue + "/" + fieldName;
    dm = DataMap.getDataMap();
    if (dm.cachedFormat[path] != null) {
      return dm.cachedFormat[path];
    }
    currentValue = DataMap.getDataField(tableName, keyValue, fieldName);
    rowData = {};
    if (((ref = dm.types[tableName]) != null ? ref.col[fieldName] : void 0) != null) {
      currentValue = dm.types[tableName].col[fieldName].renderValue(currentValue, keyValue, rowData);
    }
    if ((currentValue == null) || currentValue === null) {
      currentValue = "";
    }
    dm.cachedFormat[path] = currentValue;
    return currentValue;
  };

  return DataMap;

})();
var DataTypeCollection,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

DataTypeCollection = (function() {
  function DataTypeCollection(tableName) {
    this.tableName = tableName;
    this.configureColumns = bind(this.configureColumns, this);
    this.verifyOrderIsUnique = bind(this.verifyOrderIsUnique, this);
    this.configureColumn = bind(this.configureColumn, this);
    this.toSave = bind(this.toSave, this);
    this.getColumn = bind(this.getColumn, this);
    this.col = {};
  }

  DataTypeCollection.prototype.getColumn = function(source) {
    var col, id, ref, s;
    if (this.col[source] != null) {
      return this.col[source];
    }
    s = source.toLowerCase().replace("_", " ");
    ref = this.col;
    for (id in ref) {
      col = ref[id];
      if (col.getName().toLowerCase().replace("_", " ") === s) {
        return col;
      }
      if (col.getSource().toLowerCase().replace("_", " ") === s) {
        return col;
      }
    }
    return null;
  };

  DataTypeCollection.prototype.toSave = function() {
    var col, functionText, output, ref, source;
    output = {};
    this.verifyOrderIsUnique();
    ref = this.col;
    for (source in ref) {
      col = ref[source];
      output[source] = col.serialize();
      if ((output[source].render != null) && typeof output[source].render === "function") {
        functionText = DataTypeCollection.renderFunctionToString(output[source].render);
        output[source]["render"] = functionText;
      }
    }
    return output;
  };

  DataTypeCollection.prototype.configureColumn = function(col, skipDeduce) {
    if (skipDeduce == null) {
      skipDeduce = false;
    }
    if ((col == null) || (col.source == null)) {
      return;
    }
    if (this.col[col.source] == null) {
      this.col[col.source] = new TableViewCol(this.tableName);
    }
    if (col.order == null) {
      col.order = Object.keys(this.col).length;
    }
    this.col[col.source].deserialize(col);
    if ((skipDeduce == null) || skipDeduce === false) {
      this.col[col.source].deduceInitialColumnType();
    }
    return this.col[col.source];
  };

  DataTypeCollection.prototype.verifyOrderIsUnique = function() {
    var col, i, len, max, name, names, order, ref, ref1, seen, source;
    seen = {};
    max = 0;
    ref = this.col;
    for (source in ref) {
      col = ref[source];
      order = col.getOrder();
      if (order != null) {
        if (seen[order] != null) {
          col.changeColumn("order", null);
        } else {
          seen[order] = true;
        }
      }
    }
    ref1 = this.col;
    for (source in ref1) {
      col = ref1[source];
      if (col.getOrder() == null) {
        while (seen[max] != null) {
          max = max + 1;
        }
        col.changeColumn("order", max);
        seen[max] = true;
      }
    }
    names = Object.keys(this.col).sort((function(_this) {
      return function(a, b) {
        return _this.col[a].getOrder() - _this.col[b].getOrder();
      };
    })(this));
    max = 0;
    for (i = 0, len = names.length; i < len; i++) {
      name = names[i];
      this.col[name].data.order = max++;
    }
    return true;
  };

  DataTypeCollection.prototype.configureColumns = function(columns, skipDeduce) {
    var col, i, len;
    if (skipDeduce == null) {
      skipDeduce = false;
    }
    for (i = 0, len = columns.length; i < len; i++) {
      col = columns[i];
      this.configureColumn(col, skipDeduce);
    }
    return true;
  };

  return DataTypeCollection;

})();
var DataSet, root,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.DataSet = DataSet = (function() {
  function DataSet(baseName) {
    this.baseName = baseName;
    this.doLoadData = bind(this.doLoadData, this);
    this.setAjaxSource = bind(this.setAjaxSource, this);
    this.data = {};
    this.useDataMap = true;
  }

  DataSet.prototype.setAjaxSource = function(url, subElement, keyElement) {
    this.subElement = subElement;
    this.keyElement = keyElement;
    this.dataSourceType = "ajax";
    this.dataSourceUrl = url;
    return true;
  };

  DataSet.prototype.doLoadData = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (_this.dataSourceType === "ajax") {
          return $.ajax({
            url: _this.dataSourceUrl
          }).done(function(rawData) {
            var dm, i, j, key, len, o;
            if ((_this.subElement != null) && _this.subElement) {
              rawData = rawData[_this.subElement];
            }
            if (_this.useDataMap) {
              dm = DataMap.getDataMap();
            }
            if (Array.isArray(rawData)) {
              for (j = 0, len = rawData.length; j < len; j++) {
                i = rawData[j];
                if (i.data != null) {
                  DataMap.addDataUpdateTable(_this.baseName, i.data.id, i.data);
                } else {
                  DataMap.addDataUpdateTable(_this.baseName, i[_this.keyElement], i);
                }
              }
            } else {
              for (i in rawData) {
                o = rawData[i];
                if (_this.keyElement != null) {
                  key = o[_this.keyElement];
                } else {
                  key = i;
                }
                if (_this.useDataMap) {
                  DataMap.addDataUpdateTable(_this.baseName, key, o);
                } else {
                  _this.data[key] = o;
                }
              }
            }
            return resolve(_this);
          }).fail(function(e) {
            return reject(e);
          });
        } else {
          return reject(new Error("Unknown "));
        }
      };
    })(this));
  };

  return DataSet;

})();
var BusyDialog, BusyState,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

BusyState = (function() {
  function BusyState() {}

  BusyState.prototype.text = "";

  BusyState.prototype.min = 0;

  BusyState.prototype.max = 0;

  BusyState.prototype.pos = 0;

  return BusyState;

})();

BusyDialog = (function() {
  BusyDialog.prototype.content = "Processing please wait";

  BusyDialog.prototype.showing = false;

  BusyDialog.prototype.busyStack = [];

  BusyDialog.prototype.callbackStack = [];

  function BusyDialog() {
    this.show = bind(this.show, this);
    this.showBusy = bind(this.showBusy, this);
    this.updatePercent = bind(this.updatePercent, this);
    this.setMinMax = bind(this.setMinMax, this);
    this.step = bind(this.step, this);
    this.waitFor = bind(this.waitFor, this);
    this.exec = bind(this.exec, this);
    this.finished = bind(this.finished, this);
    this.template = Handlebars.compile('<div class="hidex" id="pleaseWaitDialog">\n    <div class="modal-body">\n        <h4 id=\'pleaseWaitDialogTitle\'>{{content}}</h4>\n\n        <div class="progress" style=\'display: none;\'>\n          <div id=\'busyProgressBar\' class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%">\n          </div>\n        </div>\n        <div class="spinner" style=\'display: none;\'>\n            <i class=\'fa fa-3x fa-asterisk fa-spin\'></i>\n        </div>\n\n        <div class=\'progressTextUnder\'>Loading</div>\n    </div>\n</div>');
    this.pleaseWaitHolder = $("body").append(this.template(this));
    this.modal = $("#pleaseWaitDialog");
    this.elTitle = $("#pleaseWaitDialogTitle");
    this.elProgressBar = $("#busyProgressBar");
    this.elProgressText = this.modal.find(".progressTextUnder");
    this.elProgressDiv = this.modal.find(".progress");
    this.elSpinner = this.modal.find(".spinner");
    this.modal.hide();
  }

  BusyDialog.prototype.finished = function() {
    this.busyStack.pop();
    if (this.busyStack.length > 0) {
      this.currentState = this.busyStack[this.busyStack.length - 1];
      return this.updatePercent();
    } else {
      this.modal.hide();
      return this.showing = false;
    }
  };

  BusyDialog.prototype.exec = function(strText, callbackFunction) {
    this.callbackStack.push(callbackFunction);
    return setTimeout((function(_this) {
      return function() {
        _this.showBusy(strText);
        return setTimeout(function() {
          callbackFunction = _this.callbackStack.pop();
          if (callbackFunction != null) {
            callbackFunction();
          } else {
            console.log("SHOULD NOT BE NULL:", strText, _this.callbackStack);
          }
          return _this.finished();
        }, 500);
      };
    })(this), 0);
  };

  BusyDialog.prototype.waitFor = function(strText, promiseValue, timeout) {
    this.showBusy(strText);
    return new Promise((function(_this) {
      return function(resolve, reject) {
        var timerValue;
        _this.setMinMax(0, 0, 0);
        if (timeout == null) {
          timeout = 30;
        }
        timerValue = setTimeout(function() {
          console.log("Timeout waiting on promise:", strText);
          return resolve(null);
        }, timeout * 1000);
        return promiseValue.then(function(result) {
          clearTimeout(timerValue);
          _this.finished();
          return resolve(result);
        });
      };
    })(this));
  };

  BusyDialog.prototype.step = function(amount) {
    if (amount == null) {
      amount = null;
    }
    if ((amount == null) || typeof amount !== "number") {
      amount = 1;
    }
    if (this.currentState.max === 0) {
      this.currentState.max = 100;
    }
    this.currentState.pos++;
    if (this.currentState.pos > this.currentState.max) {
      this.currentState.pos = this.currentState.max;
    }
    return this.updatePercent();
  };

  BusyDialog.prototype.setMinMax = function(min, max, newPos) {
    if (newPos == null) {
      newPos = 0;
    }
    this.elProgressText.html("");
    this.lastPercent = -1;
    this.currentState.min = min;
    this.currentState.max = max;
    return this.updatePercent(newPos);
  };

  BusyDialog.prototype.updatePercent = function(newPos) {
    var percent;
    if (newPos == null) {
      newPos = null;
    }
    if (newPos != null) {
      this.currentState.pos = newPos;
    }
    this.elTitle.html(this.currentState.text);
    if (this.currentState.pos === 0 && this.currentState.max === 0) {
      this.elProgressDiv.hide();
      this.elSpinner.show();
      this.elProgressBar.attr("aria-valuenow", 0).css("width", 0);
    } else {
      percent = Math.floor((this.currentState.pos / this.currentState.max) * 100) + "%";
      if (percent === this.lastPercent) {
        return;
      }
      this.elProgressDiv.show();
      this.elSpinner.hide();
      if (this.currentState.pos + 1 === this.currentState.max) {
        percent = "100%";
      }
      this.elProgressText.html(this.currentState.pos + " of " + this.currentState.max + " (" + percent + ")");
      this.elProgressBar.css("width", percent);
      this.elProgressBar.attr({
        "aria-valuenow": this.currentState.pos,
        "aria-valuemin": this.currentState.min,
        "aria-valuemax": this.currentState.max
      });
    }
    return true;
  };

  BusyDialog.prototype.showBusy = function(strText, options) {
    var name, state, val;
    state = new BusyState();
    state.text = strText;
    this.lastPercent = -1;
    this.busyStack.push(state);
    this.currentState = state;
    if (typeof options === "object") {
      for (name in options) {
        val = options[name];
        this[name] = val;
      }
    }
    this.updatePercent();
    this.showing = true;
    return this.show();
  };

  BusyDialog.prototype.show = function() {
    var h, left, mh, mw, otop, top, w;
    w = $(window).width();
    h = $(window).height();
    otop = $(window).scrollTop();
    mw = this.modal.width();
    mh = this.modal.height();
    left = (w - mw) / 2;
    top = (h - mh) / 2;
    this.modal.show();
    return this.modal.css({
      position: "fixed",
      left: left,
      top: top
    });
  };

  return BusyDialog;

})();

$(function() {
  return window.globalBusyDialog = new BusyDialog();
});
var ModalDialog,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

ModalDialog = (function() {
  ModalDialog.prototype.content = "Default content";

  ModalDialog.prototype.title = "Default title";

  ModalDialog.prototype.ok = "Ok";

  ModalDialog.prototype.close = "Close";

  ModalDialog.prototype.showFooter = true;

  ModalDialog.prototype.showOnCreate = true;

  ModalDialog.prototype.position = 'top';

  ModalDialog.prototype.formWrapper = null;

  ModalDialog.prototype.makeFormDialog = function() {
    return this.close = "Cancel";
  };

  ModalDialog.prototype.getForm = function() {
    if ((this.formWrapper == null) || !this.formWrapper) {
      this.formWrapper = new FormWrapper();
    }
    return this.formWrapper;
  };

  function ModalDialog(options) {
    this.show = bind(this.show, this);
    this.hide = bind(this.hide, this);
    this.onButton2 = bind(this.onButton2, this);
    this.onButton1 = bind(this.onButton1, this);
    this.onClose = bind(this.onClose, this);
    this.getForm = bind(this.getForm, this);
    this.makeFormDialog = bind(this.makeFormDialog, this);
    var name, val;
    this.gid = GlobalValueManager.NextGlobalID();
    this.template = Handlebars.compile('<div class="modal" id="modal{{gid}}" tabindex="-1" role="dialog" aria-hidden="true" style="display: none;">\n	<div class="modal-dialog">\n		<div class="modal-content">\n			<div class="modal-header bg-primary">\n				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>\n				<h4 class="modal-title">{{title}}</h4>\n			</div>\n			<div class="modal-body">\n				<p>\n				{{{content}}}\n				</p>\n			</div>\n\n			{{#if showFooter}}\n			<div class="modal-footer">\n				{{#if close}}\n				<button class="btn btn-sm btn-default btn1" type="button" data-dismiss="modal">{{close}}</button>\n				{{/if}}\n				{{#if ok}}\n				<button class="btn btn-sm btn-primary btn2" type="button" data-dismiss="modal"><i class="fa fa-check"></i> {{ok}}</button>\n				{{/if}}\n			</div>\n			{{/if}}\n\n		</div>\n	</div>\n</div>');
    if (typeof options === "object") {
      for (name in options) {
        val = options[name];
        this[name] = val;
      }
    }
    if (this.showOnCreate) {
      this.show();
    }
  }

  ModalDialog.prototype.onClose = function() {
    return true;
  };

  ModalDialog.prototype.onButton1 = function() {
    console.log("Default on button 1");
    this.hide();
    return true;
  };

  ModalDialog.prototype.onButton2 = function(e) {
    if (this.formWrapper != null) {
      this.formWrapper.onSubmitAction(e);
    } else {
      console.log("Default on button 2");
    }
    this.hide();
    return true;
  };

  ModalDialog.prototype.hide = function() {
    return this.modal.modal('hide');
  };

  ModalDialog.prototype.show = function(options) {
    var html;
    html = this.template(this);
    $("body").append(html);
    this.modal = $("#modal" + this.gid);
    this.modal_body = this.modal.find(".modal-body");
    if (this.formWrapper != null) {
      this.modal_body.append(this.formWrapper.getContent());
      this.formWrapper.show();
    }
    this.modal.modal(options);
    this.modal.on("hidden.bs.modal", (function(_this) {
      return function() {
        _this.modal.remove();
        return _this.onClose();
      };
    })(this));
    this.modal.find(".btn1").bind("click", (function(_this) {
      return function() {
        return _this.onButton1();
      };
    })(this));
    this.modal.find(".btn2").bind("click", (function(_this) {
      return function(e) {
        e.preventDefault();
        e.stopPropagation();
        options = {};
        _this.modal.find("input,select").each(function(idx, el) {
          var name, val;
          name = $(el).attr("name");
          val = $(el).val();
          return options[name] = val;
        });
        if (_this.onButton2(e, options) === true) {
          _this.onClose();
        }
        return true;
      };
    })(this));
    if (this.position === "center") {
      return this.modal.css({
        'margin-top': (function(_this) {
          return function() {
            return Math.max(0, $(window).scrollTop() + ($(window).height() - _this.modal.height()) / 2);
          };
        })(this)
      });
    }
  };

  return ModalDialog;

})();


/*		if @formWrapper?
			setTimeout ()=>
				@formWrapper.onAfterShow()
			, 10
 */
var FormField, substringMatcher,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

substringMatcher = function(strs) {
  return function(q, cb) {
    var i, len, matches, o, substrRegex;
    matches = [];
    substrRegex = new RegExp(q, 'i');
    for (i = 0, len = strs.length; i < len; i++) {
      o = strs[i];
      if (substrRegex.test(o)) {
        matches.push(o);
      }
    }
    return cb(matches);
  };
};

FormField = (function() {
  FormField.prototype.submit = "Submit";

  function FormField(fieldName, label, value, type, attrs) {
    this.fieldName = fieldName;
    this.label = label;
    this.value = value;
    this.type = type;
    this.attrs = attrs != null ? attrs : {};
    this.onAfterShow = bind(this.onAfterShow, this);
    this.onPressEscape = bind(this.onPressEscape, this);
    this.onPressEnter = bind(this.onPressEnter, this);
    this.makeTypeahead = bind(this.makeTypeahead, this);
    this.getHtml = bind(this.getHtml, this);
    this.html = this.getHtml();
  }

  FormField.prototype.getHtml = function() {
    return "<input name='" + this.fieldName + "' id='" + this.fieldName + "' type='" + this.type + "' value='" + this.value + "' class='form-control' />";
  };

  FormField.prototype.makeTypeahead = function(options) {
    return this.typeaheadOptions = options;
  };

  FormField.prototype.onPressEnter = function() {};

  FormField.prototype.onPressEscape = function() {};

  FormField.prototype.onAfterShow = function() {
    if (this.typeaheadOptions != null) {
      this.el.addClass(".typeahead");
      this.el.typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      }, {
        name: 'options',
        source: substringMatcher(this.typeaheadOptions)
      });
      this.el.bind("typeahead:select", (function(_this) {
        return function(ev, suggestion) {
          return console.log("DID CHANGE:", suggestion);
        };
      })(this));
    }
    return this.el.bind("keypress", (function(_this) {
      return function(e) {
        if (e.keyCode === 13) {
          _this.onPressEnter(e);
          return false;
        }
        if (e.keyCode === 27) {
          _this.onPressEscape(e);
          return false;
        }
        return true;
      };
    })(this));
  };

  return FormField;

})();
var FormWrapper,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

FormWrapper = (function() {
  function FormWrapper(holderElement, options) {
    this.backElementsFullWidth = bind(this.backElementsFullWidth, this);
    this.putElementsFullWidth = bind(this.putElementsFullWidth, this);
    this.getContent = bind(this.getContent, this);
    this.show = bind(this.show, this);
    this.onAfterShow = bind(this.onAfterShow, this);
    this.onSubmitAction = bind(this.onSubmitAction, this);
    this.onSubmit = bind(this.onSubmit, this);
    this.getHtml = bind(this.getHtml, this);
    this.setPath = bind(this.setPath, this);
    this.appendPathFieldWidgets = bind(this.appendPathFieldWidgets, this);
    this.addPathField = bind(this.addPathField, this);
    this.addSubmit = bind(this.addSubmit, this);
    this.addInput = bind(this.addInput, this);
    this.addMultiselect = bind(this.addMultiselect, this);
    this.addTagsInput = bind(this.addTagsInput, this);
    this.addTextInput = bind(this.addTextInput, this);
    var name, val;
    this.gid = "form" + GlobalValueManager.NextGlobalID();
    if (!$(holderElement).length) {
      holderElement = "<form id='" + this.gid + "' class='form-horizontal' role='form'/>";
    }
    this.elementHolder = $(holderElement);
    this.fields = [];
    this.isFullWidth = false;
    Handlebars.registerHelper("getNumber", function(data) {
      var key, value;
      for (key in data) {
        value = data[key];
        if (key === "number") {
          return value;
        }
      }
      return null;
    });
    this.templateFormFieldText = Handlebars.compile('<div class="form-group">\n    <label for="{{fieldName}}" class=\'control-label col-sm-2\'> {{label}} </label>\n    <div class=\'col-sm-10\'>\n            <input class="form-control" type="{{type}}" id="{{fieldName}}" value="{{value}}" name="{{fieldName}}"\n                {{#each attrs}}\n                {{@key}}="{{this}}"\n                {{/each}}\n            />\n        <div id="{{fieldName}}error" class="text-danger"></div>\n    </div>\n</div>');
    this.templateSelectFieldText = Handlebars.compile('<div class="form-group">\n    <label for="{{fieldName}}" class=\'control-label col-sm-2\'> {{label}} </label>\n    <div class=\'col-sm-10\'>\n            <select class="form-control" id="{{fieldName}}" name="{{fieldName}}"\n                {{#each attrs}}\n                {{@key}}="{{this}}"\n                {{/each}}\n            >\n                {{#each options}}\n                    <option value="{{this}}">{{this}}</option>\n                {{/each}}\n            </select>\n        <div id="{{fieldName}}error" class="text-danger"></div>\n    </div>\n</div>');
    this.templateFormSubmitButton = Handlebars.compile('<div class="form-group">\n    <label for="{{fieldName}}" class=\'control-label col-sm-5\'> {{label}} </label>\n    <div class=\'col-sm-7\'>\n           <button class="btn btn-sm btn-primary btn2" type="submit" data-dismiss="modal"\n                {{#each attrs}}\n                {{@key}}="{{this}}"\n                {{/each}}\n            ><i class="fa fa-check"></i> {{submit}}</button>\n    </div>\n</div>');
    this.templatePathField = Handlebars.compile('<div class="form-group">\n    <label for="{{fieldName}}" class=\'control-label col-sm-2 label-pathfield\'> {{label}} </label>\n    <div class=\'col-sm-10 pathfield\' id=\'pathfield-widget-{{getNumber attrs}}\'>\n        <!--\n        Here, path-field input will be put on\n        -->\n    </div>\n</div>');
    if (typeof options === "object") {
      for (name in options) {
        val = options[name];
        this[name] = val;
      }
    }
  }

  FormWrapper.prototype.addTextInput = function(fieldName, label, value, attrs, fnValidate) {
    return this.addInput(fieldName, label, value, "text", attrs, fnValidate);
  };

  FormWrapper.prototype.addTagsInput = function(fieldName, label, value, attrs, fnValidate) {
    var field;
    field = this.addInput(fieldName, label, value, "text", attrs, fnValidate);
    field.superAfterShow = field.onAfterShow;
    field.onAfterShow = function() {
      this.el.selectize({
        plugins: ['remove_button'],
        delimiter: ',',
        persist: false,
        create: function(input) {
          console.log("Adding[" + input + "]");
          return {
            value: input,
            text: input
          };
        }
      });
      return this.superAfterShow();
    };
    return field;
  };

  FormWrapper.prototype.addMultiselect = function(fieldName, label, value, attrs, fnValidate) {
    var field;
    attrs = $.extend(attrs, {
      multiple: 'multiple'
    });
    field = this.addInput(fieldName, label, value, "select", attrs, fnValidate);
    field.superAfterShow = field.onAfterShow;
    field.onAfterShow = function() {
      if (!Array.isArray(value)) {
        value = value.split(',');
      }
      this.el.multiSelect();
      this.el.multiSelect('select', value);
      return this.superAfterShow();
    };
    return field;
  };

  FormWrapper.prototype.addInput = function(fieldName, label, value, type, attrs, fnValidate) {
    var field;
    if (type == null) {
      type = "text";
    }
    if (attrs == null) {
      attrs = {};
    }
    type = type === "boolean" ? "checkbox" : type;
    if (type === "checkbox" && value === 1) {
      attrs.checked = "checked";
    }
    value = type === "checkbox" ? 1 : value;
    field = new FormField(fieldName, label, value, type, attrs);
    this.fields.push(field);
    return field;
  };

  FormWrapper.prototype.addSubmit = function(fieldName, label, value, attrs) {
    var field;
    if (attrs == null) {
      attrs = {};
    }
    field = new FormField(fieldName, label, value, "submit", attrs);
    this.fields.push(field);
    return field;
  };

  FormWrapper.prototype.addPathField = function(fieldName, tableName, columnName, attrs) {
    var field, widget;
    if (attrs == null) {
      attrs = {};
    }
    widget = new WidgetTag("div", "form-pathfield form-control", "form-widget-" + this.fields.length);
    if (attrs.type === "custom") {
      widget.removeClass("form-control");
      widget.addClass("custom");
    } else if (attrs.type === "calculation") {
      widget.addClass("calculation");
    }
    field = new FormField(fieldName, columnName, "", "pathfield", {
      "table": tableName,
      "column": columnName,
      "pathfield-widget": widget,
      "number": this.fields.length
    });
    this.fields.push(field);
    return field;
  };

  FormWrapper.prototype.appendPathFieldWidgets = function() {
    var field, i, len, ref, results, widget;
    ref = this.fields;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      field = ref[i];
      if (field.type === "pathfield") {
        widget = field.attrs["pathfield-widget"];
        this.elementHolder.find("#pathfield-widget-" + field.attrs['number']).empty();
        results.push(this.elementHolder.find("#pathfield-widget-" + field.attrs['number']).append(widget.getTag()));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  FormWrapper.prototype.setPath = function(tableName, idValue) {
    var field, i, len, ref, widget;
    ref = this.fields;
    for (i = 0, len = ref.length; i < len; i++) {
      field = ref[i];
      if (field.type === "pathfield") {
        widget = field.attrs["pathfield-widget"];
        widget.bindToPath(tableName, idValue, field.attrs["column"]);
      }
    }
    return true;
  };

  FormWrapper.prototype.getHtml = function() {
    var content, field, i, len, ref;
    content = "<form id='" + this.gid + "' class='form-horizontal' role='form'>";
    ref = this.fields;
    for (i = 0, len = ref.length; i < len; i++) {
      field = ref[i];
      if (field.type === 'select') {
        field.options = field.attrs.options;
        delete field.attrs.options;
        content += this.templateSelectFieldText(field);
      } else if (field.type === 'submit') {
        content += this.templateFormSubmitButton(field);
      } else if (field.type === 'pathfield') {
        content += this.templatePathField(field);
      } else {
        content += this.templateFormFieldText(field);
      }
    }
    content += "</form>";
    return content;
  };

  FormWrapper.prototype.onSubmit = function() {
    return console.log("SUBMIT");
  };

  FormWrapper.prototype.onSubmitAction = function(e) {
    var field, i, len, ref;
    ref = this.fields;
    for (i = 0, len = ref.length; i < len; i++) {
      field = ref[i];
      this[field.fieldName] = field.el.val();
    }
    this.onSubmit(this);
    if (e != null) {
      e.preventDefault();
      e.stopPropagation();
    }
    return false;
  };

  FormWrapper.prototype.onAfterShow = function() {
    var elForm, field, firstField, i, len, ref;
    firstField = null;
    elForm = $("#" + this.gid);
    ref = this.fields;
    for (i = 0, len = ref.length; i < len; i++) {
      field = ref[i];
      field.el = elForm.find("#" + field.fieldName);
      field.onAfterShow();
      if (!firstField) {
        firstField = field;
        firstField.el.focus();
      }
      field.onPressEnter = (function(_this) {
        return function(e) {
          console.log("field.onPressEnter:", e);
          return _this.onSubmitAction(e);
        };
      })(this);
    }
    elForm.submit(this.onSubmitAction);
    return true;
  };

  FormWrapper.prototype.show = function() {
    this.elementHolder.append(this.getHtml());
    this.appendPathFieldWidgets();
    setTimeout((function(_this) {
      return function() {
        return _this.onAfterShow();
      };
    })(this), 10);
    return true;
  };

  FormWrapper.prototype.getContent = function() {
    return this.elementHolder;
  };

  FormWrapper.prototype.putElementsFullWidth = function() {
    var buttonElements, inputElements, labelElements;
    if (this.isFullWidth) {
      return;
    }
    console.log("Make Full Width");
    inputElements = this.elementHolder.find("div[class^=col-sm-]");
    inputElements.addClass("form-input-fullwidth-custom");
    labelElements = this.elementHolder.find("label");
    labelElements.addClass("form-label-fullwidth-custom");
    buttonElements = this.elementHolder.find("button");
    buttonElements.addClass("form-button-fullwidth-custom");
    return this.isFullWidth = true;
  };

  FormWrapper.prototype.backElementsFullWidth = function() {
    var buttonElements, inputElements, labelElements;
    if (!this.isFullWidth) {
      return;
    }
    console.log("Take off Full Width");
    inputElements = this.elementHolder.find("div[class^=col-sm-]");
    inputElements.removeClass("form-input-fullwidth-custom");
    labelElements = this.elementHolder.find("label");
    labelElements.removeClass("form-label-fullwidth-custom");
    buttonElements = this.elementHolder.find("button");
    buttonElements.removeClass("form-button-fullwidth-custom");
    return this.isFullWidth = false;
  };

  return FormWrapper;

})();
var ImageViewer,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

ImageViewer = (function() {
  ImageViewer.prototype.boundaryValue_Width = 400;

  ImageViewer.prototype.boundaryValue_Height = 300;

  function ImageViewer(holderElement, image, number) {
    this.render = bind(this.render, this);
    this.drawNumber = bind(this.drawNumber, this);
    this.drawImage = bind(this.drawImage, this);
    this.setSize = bind(this.setSize, this);
    this.setNumber = bind(this.setNumber, this);
    this.setImage = bind(this.setImage, this);
    this.setData = bind(this.setData, this);
    if (!$(holderElement).length) {
      throw new Error("Element with selector" + holderElement + " not found for ImageStrip");
    }
    this.elementHolder = $(holderElement);
    this.gid = GlobalValueManager.NextGlobalID();
    this.imgElement = image;
    this.number = number;
    this.numberBody = $("<div />", {
      "class": "number_body",
      id: "number_body" + this.gid
    });
    this.imgViewerBody = new WidgetTag("div", "container-fluid image-wrapper", "image-wrapper" + this.gid);
    true;
  }

  ImageViewer.prototype.setData = function(data) {
    var isChanged;
    isChanged = false;
    if ((data.image != null) && this.imgElement !== data.image) {
      this.imgElement = data.image;
      isChanged = true;
    }
    if ((data.number != null) && this.number !== data.number) {
      this.number = data.number;
      isChanged = true;
    }
    if (isChanged) {
      this.render();
    }
    return isChanged;
  };

  ImageViewer.prototype.setImage = function(imgElement) {
    this.imgElement = imgElement;
  };

  ImageViewer.prototype.setNumber = function(number1) {
    this.number = number1;
  };

  ImageViewer.prototype.setSize = function(w, h) {
    this.elementHolder.width(w);
    this.elementHolder.height(h);
    if (parseInt(w) < this.boundaryValue_Width || parseInt(h) < this.boundaryValue_Height) {
      this.numberBody.find(".numberCircle").addClass("numberCircle_Small");
      this.numberBody.find(".numberCircle").removeClass("numberCircle");
    }
    return true;
  };

  ImageViewer.prototype.drawImage = function() {
    var ref;
    if (((ref = this.imgElement) != null ? ref.tagName : void 0) === "IMG") {
      this.imgViewerBody.el.empty();
      this.imgViewerBody.add("img", "image-rendered", "image_rendered" + this.gid, {
        "src": this.imgElement.src
      });
    }
    this.elementHolder.append(this.imgViewerBody.el);
    this.imgViewerBody.show();
    return true;
  };

  ImageViewer.prototype.drawNumber = function(number) {
    if (number >= 0) {
      this.numberBody.empty();
      this.numberBody.append($("<span class='numberCircle'>" + (parseInt(number) + 1) + "</span>"));
      this.elementHolder.append(this.numberBody);
    }
    return true;
  };

  ImageViewer.prototype.render = function() {
    if (this.imgElement != null) {
      this.drawNumber(this.number);
      this.drawImage();
    }
    return true;
  };

  return ImageViewer;

})();
var Scripts, doLoadScript;

Scripts = {};

doLoadScript = function(url) {
  if (Scripts[url] != null) {
    return Scripts[url];
  }
  return Scripts[url] = new Promise(function(resolve, reject) {
    var head, oScript;
    oScript = document.createElement("script");
    oScript.type = "text/javascript";
    oScript.onerror = function(oError) {
      console.log("[" + url + "] Script load error:", oError.toString());
      return resolve(true);
    };
    oScript.onload = function() {
      return resolve(true);
    };
    head = document.head || document.getElementsByTagName("head")[0];
    head.appendChild(oScript);
    return oScript.src = url;
  });
};
var MathEngine, globalMathEngine,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

globalMathEngine = null;

MathEngine = (function() {
  function MathEngine() {
    this.calculate = bind(this.calculate, this);
    this.setValues = bind(this.setValues, this);
    math["import"]({
      IF: function(cond, a, b) {
        if (cond) {
          return a;
        }
        return b;
      }
    });
    this.parser = math.parser();
  }

  MathEngine.getEngine = function() {
    if (globalMathEngine == null) {
      globalMathEngine = new MathEngine();
    }
    return globalMathEngine;
  };

  MathEngine.prototype.setValues = function(scope, prefix) {
    var txt, value, varName;
    for (varName in scope) {
      value = scope[varName];
      if (value == null) {
        continue;
      }
      txt = prefix + varName.replace(/[^a-zA-Z0-9]/g, "").toLowerCase();
      if (typeof value === "object") {
        if (value.getTime != null) {
          this.parser.set(txt, value);
        } else {
          this.setValues(value, txt + "_");
        }
      } else {
        this.parser.set(txt, value);
      }
    }
    return true;
  };

  MathEngine.prototype.calculate = function(expression, scope) {
    var e, result;
    try {
      if (this.parser == null) {
        this.init();
      }
      expression = expression.toLowerCase();
      this.setValues(scope, "");
      result = this.parser["eval"](expression, scope);
      return result;
    } catch (error) {
      e = error;
      console.log("MathEngine error:", e, "in expression", expression, "scope:", scope);
      return 0;
    }
  };

  return MathEngine;

})();

/*

 Class:  MillerColumns
 =====================================================================================

 This is class to render MillerColumns using given element

 @example:
 new MillerColumns $("#container"), isReadOnly
 */
var MillerColumns,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

MillerColumns = (function() {
  function MillerColumns(elMillerHolder, isReadOnly) {
    this.elMillerHolder = elMillerHolder;
    this.isReadOnly = isReadOnly;
    this.onSelected = bind(this.onSelected, this);
    this.filterDataWithParentCategory = bind(this.filterDataWithParentCategory, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.render = bind(this.render, this);
  }

  MillerColumns.prototype.setData = function(millerData) {
    this.millerData = millerData;
  };

  MillerColumns.prototype.render = function() {
    if (!$.fn.millerColumn) {
      console.log('Error: millerColumn plugin js is not included');
      return;
    }
    this.millerColumn = this.elMillerHolder.millerColumn({
      isReadOnly: this.isReadOnly,
      initData: this.millerData
    });
    return this.bindEvents();
  };

  MillerColumns.prototype.bindEvents = function() {
    if (!this.millerColumn) {
      return;
    }
    return this.elMillerHolder.on("item-selected", ".miller-col-list-item", (function(_this) {
      return function(e, data) {
        _this.filterDataWithParentCategory(data.categoryId, data.itemId);
        return _this.onSelected(e, data);
      };
    })(this));
  };

  MillerColumns.prototype.filterDataWithParentCategory = function(categoryId, parentId) {
    var parentItem, subItems;
    subItems = [];
    parentItem = false;
    $.each(this.millerData.items, function(i, item) {
      if (item.categoryId === categoryId && !parentItem) {
        parentItem = item;
      }
      if (item.parentId === parentId && item.categoryId === categoryId) {
        return subItems.push(item);
      }
    });
    parentItem.items = subItems;
    return this.elMillerHolder.millerColumn("addCol", parentItem);
  };

  MillerColumns.prototype.onSelected = function(event, data) {
    return console.log('item is selected with data ', data);
  };

  return MillerColumns;

})();
var DynamicNav,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

DynamicNav = (function() {
  var inverse, staticTop;

  staticTop = false;

  inverse = false;

  function DynamicNav(holderElement) {
    this.handleClick = bind(this.handleClick, this);
    this.render = bind(this.render, this);
    if (typeof holderElement === 'string' && !$(holderElement).length) {
      throw new Error("Element with selector " + holderElement + " not found for nav");
    }
    if (typeof holderElement === 'string') {
      holderElement = $(holderElement);
    }
    this.gid = GlobalValueManager.NextGlobalID();
    this.navElements = [];
    this.elementHolder = holderElement;
    this.navBarHolder = $("<nav />", {
      "class": "navbar navbar-default",
      role: "navigation",
      id: "nav_" + this.gid
    });
    this.navBarBody = $("<div />", {
      "class": "container-fluid"
    });
  }

  DynamicNav.prototype.internalProcessElements = function() {
    var e, i, len, ref;
    ref = this.navElements;
    for (i = 0, len = ref.length; i < len; i++) {
      e = ref[i];
      if (e.__proto__.hasOwnProperty('getHtml') && typeof e.__proto__.getHtml === 'function') {
        this.navBarBody.append(e.getHtml());
      } else {
        console.log("The element " + e.constructor.name + " has not implemented getHtml() method");
      }
    }
    this.navBarHolder.html(this.navBarBody);
    return this.navBarHolder.addClass((this.staticTop ? 'navbar-static-top' : '') + " " + (this.inverse ? 'navbar-inverse' : ''));
  };

  DynamicNav.prototype.render = function() {
    var dropdownElements, element, i, item, j, k, key, len, len1, len2, ref, ref1, results;
    this.internalProcessElements();
    this.elementHolder.append(this.navBarHolder);
    dropdownElements = this.navElements.filter(function(e) {
      return e.constructor.name === 'NavDropDown';
    });
    if (dropdownElements.length) {
      for (key = i = 0, len = dropdownElements.length; i < len; key = ++i) {
        element = dropdownElements[key];
        ref = element.dropdownItems;
        for (key = j = 0, len1 = ref.length; j < len1; key = ++j) {
          item = ref[key];
          this.elementHolder.find("#dd" + element.gid + "_" + key).on("click", item.callback);
        }
      }
    }
    ref1 = this.navElements;
    results = [];
    for (k = 0, len2 = ref1.length; k < len2; k++) {
      element = ref1[k];
      if (element.gid != null) {
        results.push(this.elementHolder.find("#" + element.gid).on("click", (function(_this) {
          return function(e) {
            return _this.handleClick(e);
          };
        })(this)));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  DynamicNav.prototype.handleClick = function(e) {
    var element, i, len, ref, results, the_gid;
    the_gid = $(e.target).attr("id");
    ref = this.navElements;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      element = ref[i];
      if (element.gid === the_gid) {
        if ((element.onClick != null) && typeof element.onClick === "function" && element.onClick(e)) {
          e.stopPropagation();
          e.preventDefault();
        }
        results.push(true);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  DynamicNav.prototype.addElement = function(element) {
    if (!(element.__proto__.hasOwnProperty("getHtml") && typeof element.__proto__.getHtml === 'function')) {
      console.log("element " + element.constructor.name + " has not implemented .getHtml method");
    }
    this.navElements.push(element);
    return this;
  };

  return DynamicNav;

})();
var NavButton,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

NavButton = (function() {
  function NavButton(value, classes, attrs) {
    this.value = value;
    this.classes = classes != null ? classes : "toolbar-btn navbar-btn";
    this.attrs = attrs != null ? attrs : {};
    this.onClick = bind(this.onClick, this);
    this.classes = this.classes ? this.classes : "toolbar-btn navbar-btn";
    if (!this.attrs.type) {
      this.attrs.type = "submit";
    }
    this.gid = "b" + GlobalValueManager.NextGlobalID();
  }

  NavButton.prototype.getHtml = function() {
    var $template;
    $template = '<button class="{{classes}}" id="{{gid}}"\n{{#each attrs}}\n	{{@key}}="{{this}}"\n{{/each}}\n>{{{value}}}</button>';
    return Handlebars.compile($template)(this);
  };

  NavButton.prototype.onClick = function() {
    console.log("Click this button: ", this);
    return true;
  };

  return NavButton;

})();
var NavDropDown;

NavDropDown = (function() {
  function NavDropDown(title, align) {
    this.title = title;
    this.align = align != null ? align : 'left';
    this.dropdownItems = [];
    this.gid = GlobalValueManager.NextGlobalID();
  }

  NavDropDown.prototype.getHtml = function() {
    var $template, anchor, element, i, itemsHtml, key, len, li, ref;
    itemsHtml = "";
    ref = this.dropdownItems;
    for (key = i = 0, len = ref.length; i < len; key = ++i) {
      element = ref[key];
      if (element.type !== 'divider') {
        anchor = $("<a />", {
          id: "dd" + this.gid + "_" + key,
          href: "#",
          html: element.text
        });
        li = $("<li	/>").append(anchor);
        itemsHtml += $("<div>").append(li).html();
      } else {
        itemsHtml += "<li role='separator' class='divider'></li>";
      }
    }
    $template = "<ul id='#" + this.gid + "' class='nav navbar-nav navbar-{{align}}'> <li class='dropdown'> <a href='#' class='dropdown-toggle' data-toggle='dropdown' role='button' aria-haspopup='true' aria-expanded='false'>" + this.title + " <span class='caret'></span></a> <ul class='dropdown-menu'>" + itemsHtml + "</ul> </ul>";
    return Handlebars.compile($template)(this);
  };

  NavDropDown.prototype.addItem = function(item) {
    return this.dropdownItems.push(item);
  };

  return NavDropDown;

})();
var NavForm;

NavForm = (function() {
  function NavForm(action, align) {
    this.action = action;
    this.align = align != null ? align : 'left';
    this.formElements = [];
  }

  NavForm.prototype.getHtml = function() {
    var $template, element, elementsHtml, i, len, ref;
    elementsHtml = "";
    ref = this.formElements;
    for (i = 0, len = ref.length; i < len; i++) {
      element = ref[i];
      if (!this.internalIsValidElement(element)) {
        console.log("element " + element.constructor.name + " has not implemented .getHtml method");
      }
      if (element.constructor.name !== 'NavButton') {
        elementsHtml += "<div class='form-group'>" + (element.getHtml()) + "</div>";
      } else {
        elementsHtml += element.getHtml();
      }
    }
    $template = "<form class='navbar-form navbar-{{align}}' method='post' action='" + this.action + "' role='search'>" + elementsHtml + "</form>";
    return Handlebars.compile($template)(this);
  };

  NavForm.prototype.addElement = function(element) {
    if (!this.internalIsValidElement(element)) {
      console.log("element " + element.constructor.name + " has not implemented .getHtml method");
    }
    return this.formElements.push(element);
  };

  NavForm.prototype.internalIsValidElement = function(element) {
    return element.__proto__.hasOwnProperty('getHtml') && typeof element.__proto__.getHtml === 'function';
  };

  return NavForm;

})();
var NavInput;

NavInput = (function() {
  function NavInput(name, classes, attrs) {
    this.name = name;
    this.classes = classes != null ? classes : "form-control";
    this.attrs = attrs != null ? attrs : {};
    this.classes = this.classes ? this.classes : "form-control";
    this.attrs.name = this.name;
    if (!this.attrs.type) {
      this.attrs.type = "text";
    }
  }

  NavInput.prototype.getHtml = function() {
    var $template;
    $template = '<input class="{{classes}}"\n{{#each attrs}}\n	{{@key}}="{{this}}"\n{{/each}}\n\n>';
    return Handlebars.compile($template)(this);
  };

  return NavInput;

})();
var NavTabs;

NavTabs = (function() {
  function NavTabs(align) {
    this.align = align != null ? align : 'left';
    this.tabElements = [];
  }

  NavTabs.prototype.getHtml = function() {
    var $template, className, element, i, key, len, ref, tabHtml;
    tabHtml = "";
    ref = this.tabElements;
    for (key = i = 0, len = ref.length; i < len; key = ++i) {
      element = ref[key];
      className = key === 0 ? 'active' : '';
      if (key === 0) {
        $("" + element.link).addClass('active');
      }
      tabHtml += "<li class='" + className + "'> <a href='" + element.link + "' data-toggle='tab'>" + element.text + "</a> </li>";
    }
    $template = "<ul data-toggle='tabs' class='nav navbar-nav navbar-{{align}}'> " + tabHtml + " </ul>";
    return Handlebars.compile($template)(this);
  };

  NavTabs.prototype.addTabLink = function(element) {
    return this.tabElements.push(element);
  };

  return NavTabs;

})();
var PopupMenuCalendar,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

PopupMenuCalendar = (function() {
  PopupMenuCalendar.prototype.autoClose = true;

  PopupMenuCalendar.prototype.onChange = function(newDate, newDateString) {
    return console.log("Unhandled onChange in PopupMenuCalendar for date=" + newDate, "datestring = " + newDateString);
  };

  function PopupMenuCalendar(value, x, y) {
    this.value = value;
    this.x = x;
    this.y = y;
    this.destroy = bind(this.destroy, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.onChange = bind(this.onChange, this);
    if ((this.x != null) && this.x && (this.x.currentTarget != null) && this.x.currentTarget) {
      this.element = $(this.x.currentTarget);
      this.x.stopPropagation();
      this.x.preventDefault();
    } else {
      this.hiddenElementId = GlobalValueManager.NextGlobalID();
      this.element = $('<input />', {
        style: 'display: none',
        id: this.hiddenElementId
      }).after('body');
    }
    this.theMoment = GlobalValueManager.GetMoment(this.value);
    if (typeof this.theMoment === "undefined" || this.theMoment === null) {
      this.showingMoment = moment();
    } else {
      this.showingMoment = moment(this.theMoment);
    }
    this.flatPickr = new flatpickr(this.element[0], {
      defaultDate: this.showingMoment.format('YYYY-MM-DD')
    });
    this.bindEvents();
    this.flatPickr.open();
  }

  PopupMenuCalendar.prototype.bindEvents = function() {
    this.flatPickr.config.onChange = (function(_this) {
      return function(dateObject, dateString) {
        _this.onChange(dateObject, dateString);
        if (_this.autoClose) {
          return _this.element[0]._flatpickr.close();
        }
      };
    })(this);
    $(document).one('click', (function(_this) {
      return function(e) {
        if (!$(e.target).parents('.flatpickr-wrapper').length) {
          return _this.flatPickr.close();
        }
      };
    })(this));
    return $(document).one('keypress', (function(_this) {
      return function(e) {
        if (e.keyCode === 27) {
          return _this.flatPickr.close();
        }
      };
    })(this));
  };

  PopupMenuCalendar.prototype.destroy = function() {
    this.element[0]._flatpickr.destroy();
    if (this.hiddenElementId) {
      return this.element.remove();
    }
  };

  return PopupMenuCalendar;

})();
var PopupMenu, PopupMenuItem,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

window.popupMenuVisible = false;

window.popupMenuHolder = null;

PopupMenuItem = (function() {
  function PopupMenuItem(name1, className1, id) {
    this.name = name1;
    this.className = className1;
    this.iconClass = "fa fa-fw";
    this.textClass = "";
    this.badge = null;
    this.link = $("<li />", {
      'data-id': id,
      'class': this.className,
      'html': this.name
    });
  }

  PopupMenuItem.prototype.getRenderedElement = function() {
    var iconElement, spanBadge;
    spanBadge = this.badge ? "<div class='badge pull-right bg-" + this.textClass + "'>" + this.badge + "</div>" : "";
    iconElement = this.iconClass.length ? "<i class='" + this.iconClass + " pull-right text-" + this.textClass + "'></i>" : "";
    if (this.textClass.length) {
      this.link.addClass("text-" + this.textClass);
    }
    return this.link.html(this.name + " " + iconElement + " " + spanBadge);
  };

  PopupMenuItem.prototype.getLink = function() {
    return this.link;
  };

  PopupMenuItem.prototype.setBadge = function(badge) {
    this.badge = badge;
    return this;
  };

  PopupMenuItem.prototype.setIcon = function(iconClass) {
    this.iconClass = iconClass;
    return this;
  };

  PopupMenuItem.prototype.setClass = function(textClass) {
    this.textClass = textClass;
    return this;
  };

  return PopupMenuItem;

})();

PopupMenu = (function() {
  PopupMenu.prototype.popupWidth = 200;

  PopupMenu.prototype.popupHeight = 0;

  PopupMenu.prototype.resize = function(popupWidth) {
    var height, i, len, linkObject, ref, width;
    this.popupWidth = popupWidth;
    this.popupHeight = window.popupMenuHolder.height();
    width = $(window).width();
    height = $(window).height();
    if (this.x < 0) {
      this.x = 0;
    }
    if (this.y < 0) {
      this.y = 0;
    }
    if (this.popupWidth > width - 40) {
      this.popupWidth = width - 40;
    }
    if (this.x + this.popupWidth + 10 > width) {
      this.x = width - this.popupWidth - 10;
    }
    window.popupMenuHolder.css({
      left: this.x,
      top: this.y,
      width: this.popupWidth
    });
    ref = this.linkObjects;
    for (i = 0, len = ref.length; i < len; i++) {
      linkObject = ref[i];
      window.popupMenuHolder.append(linkObject.getRenderedElement());
    }
    window.popupMenuHolder.show();
    return true;
  };

  function PopupMenu(title, x, y) {
    var html, id, values;
    this.title = title;
    this.x = x;
    this.y = y;
    this.onGlobalMouseDown = bind(this.onGlobalMouseDown, this);
    this.onGlobalEscKey = bind(this.onGlobalEscKey, this);
    this.addItem = bind(this.addItem, this);
    this.setMultiColumn = bind(this.setMultiColumn, this);
    this.closeTimer = bind(this.closeTimer, this);
    this.resize = bind(this.resize, this);
    this.linkObjects = [];
    if ((this.x != null) && this.x && (this.x.currentTarget != null) && this.x.currentTarget) {
      values = GlobalValueManager.GetCoordsFromEvent(this.x);
      this.x.stopPropagation();
      this.x.preventDefault();
      this.x = values.x - 150;
      this.y = values.y - 10;
    }
    if (this.x < 0) {
      this.x = 0;
    }
    if (this.y < 0) {
      this.y = 0;
    }
    if (typeof window.popupMenuHolder === "undefined" || !window.popupMenuHolder) {
      window.popupMenuVisible = false;
      id = GlobalValueManager.NextGlobalID();
      html = $("<ul />", {
        "class": "PopupMenu",
        id: "popup" + id
      });
      window.popupMenuHolder = $(html);
      window.popupMenuTimer = 0;
      $("body").append(window.popupMenuHolder);
      $(window.popupMenuHolder).on("mouseout", (function(_this) {
        return function(e) {
          if (window.popupMenuVisible) {
            if (window.popupMenuTimer) {
              clearTimeout(window.popupMenuTimer);
            }
            window.popupMenuTimer = setTimeout(_this.closeTimer, 750);
            false;
          }
          return true;
        };
      })(this));
      $(window.popupMenuHolder).on("mouseover", (function(_this) {
        return function(e) {
          if (window.popupMenuVisible) {
            if (window.popupMenuTimer) {
              clearTimeout(window.popupMenuTimer);
            }
            window.popupMenuTimer = 0;
          }
          return true;
        };
      })(this));
    }
    window.popupMenuVisible = true;
    window.popupMenuHolder.removeClass("multicol");
    html = "<li class='title'>" + this.title + "</li>";
    window.popupMenuHolder.html(html);
    setTimeout(function() {
      return window.popupMenuHolder.show();
    }, 10);
    globalKeyboardEvents.once("global_mouse_down", this.onGlobalMouseDown);
    globalKeyboardEvents.once("esc", this.onGlobalEscKey);
    this.resize(this.popupWidth);
    this.colCount = 1;
    this.menuItems = {};
    this.menuData = {};
  }

  PopupMenu.prototype.closeTimer = function() {
    window.popupMenuHolder.hide();
    window.popupMenuVisible = false;
    window.popupMenuTimer = 0;
    globalKeyboardEvents.off("global_mouse_down", this.onGlobalMouseDown);
    globalKeyboardEvents.off("esc", this.onGlobalEscKey);
    return false;
  };

  PopupMenu.prototype.setMultiColumn = function(colCount, colWidth) {
    this.colCount = colCount;
    if (colWidth == null) {
      colWidth = this.popupWidth;
    }
    this.resize(this.colCount * colWidth);
    window.popupMenuHolder.addClass("multicol");
    $(".multicol").css("columnCount", this.colCount);
    $(window.popupMenuHolder).find(".title").css("columnSpan", "all");
    return console.log("FIND:", $(".title"));
  };

  PopupMenu.prototype.addItem = function(name, callbackFunction, callbackData, className) {
    var id, link, linkObject;
    id = GlobalValueManager.NextGlobalID();
    this.menuItems[id] = callbackFunction;
    this.menuData[id] = callbackData;
    if (typeof className === "undefined") {
      className = "popupMenuItem";
    }
    linkObject = new PopupMenuItem(name, className, id);
    this.linkObjects.push(linkObject);
    link = linkObject.link;
    if (this.colCount > 0) {
      link.addClass("multicol");
    }
    link.on("click", (function(_this) {
      return function(e) {
        var dataId;
        e.preventDefault();
        e.stopPropagation();
        _this.closeTimer();
        dataId = $(e.target).attr("data-id");
        if (dataId) {
          _this.menuItems[dataId](e, _this.menuData[dataId]);
        }
        return true;
      };
    })(this));
    this.resize(this.popupWidth);
    return linkObject;
  };

  PopupMenu.prototype.onGlobalEscKey = function(e) {
    this.closeTimer();
    return false;
  };

  PopupMenu.prototype.onGlobalMouseDown = function(e) {
    console.log("POPUP MENU, onGlobalMouseDown", window.popupMenuVisible);
    if (!window.popupMenuVisible) {
      return false;
    }
    setTimeout(this.closeTimer, 200);
    return false;
  };

  return PopupMenu;

})();
var TableDropdownMenu,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

TableDropdownMenu = (function() {
  TableDropdownMenu.prototype.setValue = function(row) {
    var col;
    col = this.columns[0];
    if ((this.config.render != null) && typeof this.config.render === "function") {
      this.elInputField.html(this.config.render(row[col], row));
    } else {
      this.elInputField.html(row[col]);
    }
    this.emitEvent("change", row[col]);
    return this.currentValue = row;
  };

  function TableDropdownMenu(HolderField, tableName, columns, options) {
    var tableRows;
    this.tableName = tableName;
    this.columns = columns;
    this.initFloatingWindow = bind(this.initFloatingWindow, this);
    this.setValue = bind(this.setValue, this);
    this.config = {
      rowHeight: 24,
      numRows: 10,
      showHeaders: false,
      width: null,
      height: null,
      render: null,
      allowEmpty: true,
      placeholder: "Select an option"
    };
    $.extend(this.config, options);
    this.currentValue = null;
    this.elInputField = $("<div class='floatingDropdownValue'/>");
    this.elCarot = $("<i class='fa fa-arrow-down floatingDropdownIcon'></i>");
    this.elHolder = $(HolderField);
    this.elHolder.addClass("floatingDropdown");
    this.elHolder.append(this.elInputField);
    this.elHolder.append(this.elCarot);
    this.elInputField.html(this.config.placeholder);
    GlobalClassTools.addEventManager(this);
    if ((this.config.allowEmpty != null) && this.config.allowEmpty === false) {
      tableRows = DataMap.getValuesFromTable(this.tableName);
      if (tableRows != null) {
        this.setValue(tableRows.shift());
      }
    }
    this.elInputField.on("click", (function(_this) {
      return function(e) {
        _this.initFloatingWindow();
        return globalKeyboardEvents.once("global_mouse_down", function(ee) {
          console.log("Onetime mouse down, closing after other events");
          setTimeout(function() {
            return _this.win.hide();
          }, 1050);
          return false;
        });
      };
    })(this));
  }

  TableDropdownMenu.prototype.initFloatingWindow = function() {
    var height, posLeft, posTop, scrollLeft, scrollTop, width;
    scrollTop = document.body.scrollTop;
    scrollLeft = document.body.scrollLeft;
    posTop = this.elInputField.offset().top;
    posLeft = this.elInputField.offset().left;
    width = this.elInputField.outerWidth(true);
    height = this.elInputField.outerHeight(true);
    if (this.config.width == null) {
      this.config.width = width;
    }
    if (this.config.height == null) {
      this.config.height = this.config.rowHeight * this.config.numRows;
    }
    if (this.win == null) {
      this.win = new FloatingSelect(posLeft + scrollLeft, posTop + scrollTop + height, this.config.width, this.config.height);
      this.win.setTable(this.tableName, this.columns, this.config);
      this.win.on("select", (function(_this) {
        return function(row) {
          _this.setValue(row);
          return _this.win.hide();
        };
      })(this));
    }
    return this.win.show();
  };

  return TableDropdownMenu;

})();
var FloatingWindow,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

FloatingWindow = (function() {
  FloatingWindow.prototype.width = 300;

  FloatingWindow.prototype.height = 200;

  FloatingWindow.prototype.parent = null;

  FloatingWindow.prototype.top = 0;

  FloatingWindow.prototype.left = 0;

  function FloatingWindow(x, y, w, h, parentHolder, options) {
    this.dockTopRight = bind(this.dockTopRight, this);
    this.destroy = bind(this.destroy, this);
    this.setSize = bind(this.setSize, this);
    this.moveTo = bind(this.moveTo, this);
    this.hide = bind(this.hide, this);
    this.show = bind(this.show, this);
    this.html = bind(this.html, this);
    this.getBodyWidget = bind(this.getBodyWidget, this);
    this.internalCreateElement = bind(this.internalCreateElement, this);
    if (options != null) {
      $.extend(this, options);
    }
    if (w != null) {
      this.width = w;
    }
    if (h != null) {
      this.height = h;
    }
    if (y != null) {
      this.top = y;
    }
    if (x != null) {
      this.left = x;
    }
    if (parentHolder != null) {
      this.parent = $(parentHolder);
    } else {
      this.parent = $("body");
    }
    this.floatingWin = null;
  }

  FloatingWindow.prototype.internalCreateElement = function() {
    if (this.floatingWin != null) {
      return;
    }
    this.floatingWin = new WidgetTag("div", "floatingWindow");
    this.floatingWin.move(this.left, this.top, this.width, this.height);
    this.floatingWin.appendTo(this.parent);
    this.floatingWin.hide();
    this.elHolder = this.floatingWin.addDiv("floatingWinBody");
    return true;
  };

  FloatingWindow.prototype.getBodyWidget = function() {
    this.internalCreateElement();
    return this.elHolder;
  };

  FloatingWindow.prototype.html = function(html) {
    return this.getBodyWidget().html(html);
  };

  FloatingWindow.prototype.show = function() {
    this.internalCreateElement();
    return this.floatingWin.show();
  };

  FloatingWindow.prototype.hide = function() {
    if (this.floatingWin != null) {
      return this.floatingWin.hide();
    }
  };

  FloatingWindow.prototype.moveTo = function(x, y) {
    this.top = y;
    this.left = x;
    if (this.floatingWin != null) {
      this.floatingWin.move(this.left, this.top, this.width, this.height);
    }
    return true;
  };

  FloatingWindow.prototype.setSize = function(w, h) {
    this.width = w;
    this.height = h;
    if (this.floatingWin != null) {
      this.floatingWin.move(this.left, this.top, this.width, this.height);
    }
    return true;
  };

  FloatingWindow.prototype.destroy = function() {
    this.floatingWin.destroy();
    return delete this.floatingWin;
  };

  FloatingWindow.prototype.dockTopRight = function(newWidth, newHeight) {
    var h, w;
    if (newWidth == null) {
      newWidth = 300;
    }
    if (newHeight == null) {
      newHeight = 120;
    }
    w = $(window).width();
    h = $(window).height();
    this.setSize(newWidth, newHeight);
    this.moveTo(w - newWidth - 20, 20);
    return true;
  };

  return FloatingWindow;

})();
var PopupTooltip, globalPopupTooltipWindow;

globalPopupTooltipWindow = null;

PopupTooltip = (function() {
  function PopupTooltip(w, h) {
    this.gid = GlobalValueManager.NextGlobalID();
    if (globalPopupTooltipWindow === null) {
      globalPopupTooltipWindow = $("<div>", {
        "class": "popupWindowTooltip",
        id: "popupWindowTooltip"
      });
    }
  }

  return PopupTooltip;

})();
var PopupWindow, globalOpenWindowList,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

globalOpenWindowList = [];

PopupWindow = (function() {
  PopupWindow.prototype.popupWidth = 600;

  PopupWindow.prototype.popupHeight = 400;

  PopupWindow.prototype.isVisible = false;

  PopupWindow.prototype.allowHorizontalScroll = false;

  PopupWindow.prototype.configurations = {
    tableName: null,
    keyValue: null,
    windowName: null,
    resizable: true,
    scrollable: true
  };

  PopupWindow.prototype.getBodyHeight = function() {
    var h;
    h = this.popupHeight;
    h -= 1;
    h -= 1;
    h -= this.windowTitle.height();
    return h;
  };

  PopupWindow.prototype.update = function() {
    if (this.configurations.scrollable) {
      return this.myScroll.refresh();
    }
  };

  PopupWindow.prototype.open = function() {
    if (this.configurations.scrollable) {
      setTimeout((function(_this) {
        return function() {
          return _this.update();
        };
      })(this), 20);
    }
    this.popupWindowHolder.show();
    this.isVisible = true;
    return true;
  };

  PopupWindow.prototype.close = function(e) {
    if (typeof e !== "undefined" && e !== null) {
      e.preventDefault();
      e.stopPropagation();
    }
    this.popupWindowHolder.hide();
    this.isVisible = false;
    return false;
  };

  PopupWindow.prototype.destroy = function() {
    var i, l, len, list;
    list = globalOpenWindowList;
    globalOpenWindowList = [];
    for (i = 0, len = list.length; i < len; i++) {
      l = list[i];
      if (l !== this) {
        globalOpenWindowList.push(l);
      }
    }
    this.close();
    this.popupWindowHolder.remove();
    return true;
  };

  PopupWindow.prototype.centerToPoint = function(x, y) {
    var height, px, py, width;
    width = $(window).width();
    height = $(window).height();
    if (this.popupWidth > width) {
      this.popupWidth = width;
    }
    if (this.popupHeight > height) {
      this.popupHeight = height;
    }
    px = x - (this.popupWidth / 2);
    py = y - (this.popupHeight / 2);
    if (px < 0) {
      px = 0;
    }
    if (py < 0) {
      py = 0;
    }
    if (px + this.popupWidth > width) {
      px = width - this.popupWidth;
    }
    if (py + this.popupHeight > height) {
      py = height - this.popupHeight;
    }
    return this.popupWindowHolder.css({
      left: this.x,
      top: this.y
    });
  };

  PopupWindow.prototype.center = function() {
    var height, width;
    width = $(window).width();
    height = $(window).height();
    this.x = (width - this.popupWidth) / 2;
    this.y = (height - this.popupHeight) / 2;
    this.y += $(window).scrollTop();
    while (this.x < 0) {
      this.x++;
      this.popupWidth--;
    }
    while (this.y < 0) {
      this.y++;
      this.popupHeight--;
    }
    console.log("Center: " + this.x + ", " + this.y + " (" + this.popupWidth + ", " + this.popupHeight + ")");
    return this.popupWindowHolder.css({
      left: this.x,
      top: this.y
    });
  };

  PopupWindow.prototype.modal = function(popupWidth, popupHeight) {
    this.popupWidth = popupWidth;
    this.popupHeight = popupHeight;
    this.shield = $("<div />");
    this.shield.css({
      zIndex: parseInt(this.popupWindowHolder.css("zIndex")) - 10,
      position: "absolute",
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      backgroundColor: "rgba(0,0,0,0.6)"
    });
    $(document).on("keypress", (function(_this) {
      return function(e) {
        console.log("KEY=", e);
        return false;
      };
    })(this));
    this.center();
    return $("body").append(this.shield);
  };

  PopupWindow.prototype.resize = function(popupWidth, popupHeight) {
    var height, scrollX, scrollY, width;
    this.popupWidth = popupWidth;
    this.popupHeight = popupHeight;
    width = $(window).width();
    height = $(window).height();
    scrollX = window.pageXOffset || document.body.scrollLeft;
    scrollY = window.pageYOffset || document.body.scrollTop;
    console.log("popupWindow " + this.title + ", width=" + width + " height=" + height + " : " + this.popupWidth + " x " + this.popupHeight + " (x=" + this.x + ", y=" + this.y + ")");
    if (this.x === 0 && this.y === 0) {
      this.center();
    }
    if (this.x < 0) {
      this.x = 0;
    }
    if (this.y < 0) {
      this.y = 0;
    }
    if (this.x - scrollX + this.popupWidth + 10 > width) {
      console.log("popupWindow " + this.title + ", moving because " + this.x + " + " + this.popupWidth + " + 10 > " + width);
      this.x = width + scrollX - this.popupWidth - 10;
    }
    this.popupHeight += 24;
    if (this.y - scrollY + this.popupHeight + 10 > height) {
      this.y = height + scrollY - this.popupHeight - 10;
    }
    while (this.x < 10) {
      this.x++;
      this.popupWidth--;
    }
    while (this.y < 10) {
      this.y++;
      this.popupHeight--;
    }
    console.log("popupWindow x=" + this.x + " y=" + this.y);
    this.popupWindowHolder.css({
      left: this.x,
      top: this.y,
      width: this.popupWidth,
      height: this.popupHeight
    });
    this.windowWrapper.css({
      left: 0,
      top: 4,
      width: this.popupWidth,
      height: this.popupHeight - 26 - 5
    });
    if (this.configurations.scrollable) {
      setTimeout((function(_this) {
        return function() {
          return _this.myScroll.refresh();
        };
      })(this), 100);
    }
    this.popupWindowHolder.show();
    this.isVisible = true;
    this.emitEvent("resize", [this.popupWidth, this.popupHeight]);
    return true;
  };

  PopupWindow.prototype.internalCheckSavedLocation = function() {
    var location;
    return false;
    if (this.configurations.tableName && this.configurations.tableName.length) {
      location = localStorage.getItem("PopupLocation_" + this.configurations.tableName);
      console.log("Loaded saved PopupLocation_" + this.configurations.tableName + ": ", location);
      if (location !== null) {
        location = JSON.parse(location);
      }
      if (location !== 0 && location !== null) {
        this.x = location.x;
        this.y = location.y;
        this.popupHeight = location.h;
        return this.popupWidth = location.w;
      }
    }
  };

  PopupWindow.prototype.internalSavePosition = function() {
    if (this.configurations.tableName !== null && this.configurations.tableName.length) {
      return localStorage.setItem("PopupLocation_" + this.configurations.tableName, JSON.stringify({
        x: this.x,
        y: this.y,
        h: this.popupHeight,
        w: this.popupWidth
      }));
    }
  };

  PopupWindow.prototype.addToolbar = function(buttonList) {
    var button, gid, i, len;
    this.toolbarHeight = 42;
    gid = "pnav" + GlobalValueManager.NextGlobalID();
    this.navBar = $("<div />", {
      id: gid,
      "class": 'popupNavBar'
    });
    this.navBar.css({
      position: "absolute",
      top: this.windowTitle.height() + 6,
      left: 0,
      height: this.toolbarHeight,
      width: "100%"
    });
    this.popupWindowHolder.append(this.navBar);
    this.toolbar = new DynamicNav("#" + gid);
    for (i = 0, len = buttonList.length; i < len; i++) {
      button = buttonList[i];
      this.toolbar.addElement(button);
    }
    this.toolbar.render();
    this.windowBodyWrapperTop.css("top", this.windowTitle.height() + 2 + this.toolbarHeight);
    this.windowWrapper.height(this.popupHeight - this.windowTitle.height() - 1 - this.toolbarHeight);
    return true;
  };

  PopupWindow.prototype.createPopupHolder = function() {
    var doMove, html, id, startHeight, startWidth, startX, startY, stopMove;
    globalOpenWindowList.push(this);
    this.toolbarHeight = 0;
    id = GlobalValueManager.NextGlobalID();
    html = $("<div />", {
      "class": "PopupWindow",
      id: "popup" + id
    });
    this.popupWindowHolder = $(html);
    $("body").append(this.popupWindowHolder);
    this.windowTitle = new WidgetTag("div", "title", "popuptitle" + id, {
      dragable: true
    });
    this.windowTitleText = this.windowTitle.add("span", "title_text");
    this.windowTitleText.html(this.title);
    this.windowClose = this.windowTitle.add("div", "closebutton", "windowclose" + id);
    this.windowClose.html("<i class='glyphicon glyphicon-remove'></i>");
    this.windowClose.el.on("click", (function(_this) {
      return function() {
        if (_this.shield != null) {
          _this.shield.remove();
        }
        if (_this.configurations && _this.configurations.keyValue) {
          return _this.close();
        } else {
          return _this.destroy();
        }
      };
    })(this));
    this.popupWindowHolder.append(this.windowTitle.el);
    this.windowScroll = $("<div />", {
      "class": "scrollcontent"
    });
    this.windowWrapper = $("<div />", {
      id: "windowwrapper" + id,
      "class": "scrollable"
    });
    this.windowWrapper.append(this.windowScroll);
    if (this.configurations.resizable) {
      this.resizable = $("<div />", {
        id: "windowResizeHandler" + id,
        "class": "resizeHandle"
      }).appendTo(this.windowWrapper);
    }
    this.windowBodyWrapperTop = $("<div />", {
      "class": "windowbody"
    }).css({
      position: "absolute",
      top: this.windowTitle.outerHeight(),
      left: 0,
      right: 0,
      bottom: 0
    }).append(this.windowWrapper);
    this.popupWindowHolder.append(this.windowBodyWrapperTop);
    if (this.configurations.scrollable) {
      this.myScroll = new IScroll("#windowwrapper" + id, {
        mouseWheel: true,
        scrollbars: true,
        bounce: false,
        resizeScrollbars: false,
        freeScroll: this.allowHorizontalScroll,
        scrollX: this.allowHorizontalScroll
      });
    }
    this.dragabilly = new Draggabilly("#popup" + id, {
      handle: "#popuptitle" + id
    });
    this.dragabilly.on("dragStart", (function(_this) {
      return function(e) {
        _this.popupWindowHolder.css("opacity", "0.5");
        return false;
      };
    })(this));
    this.dragabilly.on("dragMove", (function(_this) {
      return function(e) {
        var h, w, x, y;
        x = _this.dragabilly.position.x;
        y = _this.dragabilly.position.y;
        w = $(window).width();
        h = $(window).height();
        if (x + 50 > w) {
          _this.dragabilly.position.x = w - 50;
        }
        if (y + 50 > h) {
          _this.dragabilly.position.y = h - 50;
        }
        if (x < -50) {
          _this.dragabilly.position.x = -50;
        }
        if (y < 0) {
          _this.dragabilly.position.y = 0;
        }
        _this.x = _this.dragabilly.position.x;
        _this.y = _this.dragabilly.position.y;
        _this.internalSavePosition();
        return false;
      };
    })(this));
    this.dragabilly.on("dragStart", (function(_this) {
      return function(e) {
        _this.popupWindowHolder.css("opacity", "0.5");
        return false;
      };
    })(this));
    this.dragabilly.on("dragEnd", (function(_this) {
      return function(e) {
        _this.popupWindowHolder.css("opacity", "1.0");
        return false;
      };
    })(this));
    startX = 0;
    startY = 0;
    startWidth = 0;
    startHeight = 0;
    doMove = (function(_this) {
      return function(e) {
        _this.popupWidth = startWidth + e.clientX - startX;
        _this.popupHeight = startHeight + e.clientY - startY;
        _this.popupWindowHolder.width(_this.popupWidth);
        _this.windowWrapper.width(_this.popupWidth);
        _this.popupWindowHolder.height(_this.popupHeight);
        _this.windowWrapper.height(_this.popupHeight - _this.windowTitle.height() - 1 - _this.toolbarHeight);
        _this.windowScroll.trigger('resize');
        _this.emitEvent("resize", [_this.popupWidth, _this.popupHeight]);
        return true;
      };
    })(this);
    stopMove = (function(_this) {
      return function(e) {
        $(document).unbind("mousemove", doMove);
        $(document).unbind("mouseup", stopMove);
        return _this.internalSavePosition();
      };
    })(this);
    return this.resizable.on("mousedown", (function(_this) {
      return function(e) {
        startX = e.clientX;
        startY = e.clientY;
        startWidth = _this.popupWindowHolder.width();
        startHeight = _this.popupWindowHolder.height();
        $(document).on('mousemove', doMove);
        return $(document).on("mouseup", stopMove);
      };
    })(this));
  };

  function PopupWindow(title, x1, y1, configurations) {
    this.title = title;
    this.x = x1;
    this.y = y1;
    this.setBackgroundColor = bind(this.setBackgroundColor, this);
    this.setTitle = bind(this.setTitle, this);
    this.html = bind(this.html, this);
    this.createPopupHolder = bind(this.createPopupHolder, this);
    this.addToolbar = bind(this.addToolbar, this);
    this.internalSavePosition = bind(this.internalSavePosition, this);
    this.internalCheckSavedLocation = bind(this.internalCheckSavedLocation, this);
    this.resize = bind(this.resize, this);
    this.modal = bind(this.modal, this);
    this.center = bind(this.center, this);
    this.centerToPoint = bind(this.centerToPoint, this);
    this.destroy = bind(this.destroy, this);
    this.close = bind(this.close, this);
    this.open = bind(this.open, this);
    this.update = bind(this.update, this);
    this.getBodyHeight = bind(this.getBodyHeight, this);
    if (typeof this.x === "undefined" || this.x < 0) {
      this.x = 0;
    }
    if (typeof this.y === "undefined" || this.y < 0) {
      this.y = 0;
    }
    GlobalClassTools.addEventManager(this);
    if ((configurations == null) || typeof configurations !== 'object') {
      configurations = {};
    }
    if (configurations.scrollable == null) {
      configurations.scrollable = true;
    }
    this.configurations = $.extend(this.configurations, configurations);
    if (this.configurations.w && this.configurations.w > 0) {
      this.popupWidth = this.configurations.w;
    }
    if (this.configurations.h && this.configurations.h > 0) {
      this.popupHeight = this.configurations.h;
    }
    this.internalCheckSavedLocation();
    this.createPopupHolder();
    this.resize(this.popupWidth, this.popupHeight);
    true;
  }

  PopupWindow.prototype.html = function(strHtml) {
    this.windowScroll.html(strHtml);
    setTimeout(this.update, 10);
    return true;
  };

  PopupWindow.prototype.setTitle = function(strHtml) {
    this.windowTitleText.html(strHtml);
    return true;
  };

  PopupWindow.prototype.setBackgroundColor = function(colorCss) {
    return this.windowWrapper.css("backgroundColor", colorCss);
  };

  return PopupWindow;

})();

$(function() {
  return $(document).on("keyup", (function(_this) {
    return function(e) {
      var win;
      if (e.keyCode === 27) {
        if ((globalOpenWindowList != null) && globalOpenWindowList.length > 0) {
          win = globalOpenWindowList.pop();
          console.log("Escape closing window:", win);
          return win.destroy();
        }
      }
    };
  })(this));
});
var TypeaheadInput,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

TypeaheadInput = (function() {
  TypeaheadInput.prototype.onKeypress = function(e) {
    var val;
    val = this.elInputField.val();
    if (e.keyCode === 27) {
      this.win.hide();
      return false;
    }
    if (e.keyCode === 13) {
      this.emitEvent("change", val);
      this.win.hide();
      return false;
    }
    if (e.keyCode === 38) {
      this.moveCellUp();
      return;
    }
    if (e.keyCode === 40) {
      this.moveCellDown();
      return;
    }
    this.setFilter(val);
    return true;
  };

  TypeaheadInput.prototype.onFocus = function(e) {
    this.emitEvent("focus", [e]);
    this.clearIcon.show();
    this.elInputField.select();
    this.initFloatingWindow();
    this.setFilter(this.elInputField.val());
    return true;
  };

  TypeaheadInput.prototype.onBlur = function(e) {
    if (!this.excludeBlurEvent) {
      this.emitEvent("blur", [e]);
      this.clearIcon.hide();
      if (this.win != null) {
        this.win.hide();
      }
    }
    return true;
  };

  TypeaheadInput.prototype.moveCellUp = function(e) {
    if (this.win.table.currentFocusCell == null) {
      this.win.table.setFocusFirstCell();
    } else {
      this.win.table.moveCellUp();
    }
    return true;
  };

  TypeaheadInput.prototype.moveCellDown = function(e) {
    if (this.win.table.currentFocusCell == null) {
      this.win.table.setFocusFirstCell();
    } else {
      this.win.table.moveCellDown();
    }
    return true;
  };

  TypeaheadInput.prototype.setFilter = function(newText) {
    this.emitEvent("filter", [newText, this.win.table]);
    return true;
  };

  function TypeaheadInput(InputField, tableName, columns, options) {
    this.tableName = tableName;
    this.columns = columns;
    this.initFloatingWindow = bind(this.initFloatingWindow, this);
    this.hideWindow = bind(this.hideWindow, this);
    this.showWindow = bind(this.showWindow, this);
    this.setFilter = bind(this.setFilter, this);
    this.moveCellDown = bind(this.moveCellDown, this);
    this.moveCellUp = bind(this.moveCellUp, this);
    this.onBlur = bind(this.onBlur, this);
    this.onFocus = bind(this.onFocus, this);
    this.onKeypress = bind(this.onKeypress, this);
    this.config = {
      rowHeight: 24,
      numRows: 10
    };
    $.extend(this.config, options);
    this.elInputField = $(InputField);
    this.elInputField.after($('<i />', {
      'class': 'fa fa-times floatingDropdownIcon',
      style: 'margin-left: -20px; float:right; display:none'
    }));
    this.clearIcon = this.elInputField.next();
    this.clearIcon.on('click', (function(_this) {
      return function(e) {
        _this.elInputField.val('');
        _this.emitEvent('change', '');
        _this.setFilter("");
        return _this.elInputField.focus();
      };
    })(this)).on('mouseover', (function(_this) {
      return function() {
        return _this.excludeBlurEvent = true;
      };
    })(this)).on('mouseleave', (function(_this) {
      return function() {
        return _this.excludeBlurEvent = false;
      };
    })(this));
    GlobalClassTools.addEventManager(this);
    this.elInputField.on("keyup", this.onKeypress);
    this.elInputField.on("focus", this.onFocus);
    this.elInputField.on("blur", this.onBlur);
    this.elInputField.on("click", this.onFocus);
  }

  TypeaheadInput.prototype.showWindow = function() {
    return this.win.show();
  };

  TypeaheadInput.prototype.hideWindow = function() {
    return this.win.hide();
  };

  TypeaheadInput.prototype.initFloatingWindow = function() {
    var height, posLeft, posTop, px, scrollLeft, scrollTop, width, winWidth;
    scrollTop = document.body.scrollTop;
    scrollLeft = document.body.scrollLeft;
    posTop = this.elInputField.offset().top;
    posLeft = this.elInputField.offset().left;
    scrollTop = 0;
    scrollLeft = 0;
    width = this.elInputField.outerWidth(true);
    height = this.elInputField.outerHeight(true);
    if (this.config.width != null) {
      width = this.config.width;
    }
    if (this.config.height != null) {
      height = this.config.height;
    }
    winWidth = $(window).width();
    if (posLeft + width > winWidth) {
      posLeft = winWidth - 10 - width;
    }
    px = this.elInputField.position();
    if (this.win == null) {
      this.win = new FloatingSelect(posLeft, posTop + height, width, this.config.rowHeight * this.config.numRows, this.elInputField.parent());
      this.win.setTable(this.tableName, this.columns);
      this.win.on("select", (function(_this) {
        return function(row) {
          var col;
          console.log("initFloatingWindow win.on 'select':", row);
          col = _this.columns[0];
          _this.elInputField.val(row[col]);
          _this.emitEvent("change", row[col]);
          return _this.win.hide();
        };
      })(this));
      this.win.on("preselect", (function(_this) {
        return function(value, itemRow) {
          console.log("initFloatingWindow preselect:", value);
          _this.elInputField.val(value);
          return _this.elInputField.select();
        };
      })(this));
    }
    this.win.show();
    return this.win.onResize();
  };

  return TypeaheadInput;

})();
var Screens, Scripts, StyleManager, Views, activateCurrentScreen, doAppendView, doLoadDependencies, doLoadScreen, doLoadView, doPopupView, doReplaceScreenContent, doShowScreen, globalWindowManager, registerStyleSheet, showScreen, showViewAsScreen;

Screens = {};

Screens.history = [];

Screens.current = 0;

Screens.popupVisible = 0;

Views = {};

Scripts = {};

StyleManager = {};

globalWindowManager = null;

registerStyleSheet = function(name, content) {
  if (StyleManager[name] == null) {
    StyleManager[name] = $("<style type='text/css' id='sheet_" + name + "'></style>");
    $("head").append(StyleManager[name]);
  }
  StyleManager[name].html(content);
  return true;
};

doReplaceScreenContent = function(screenName) {
  var content, el, htmlContentEscaped;
  htmlContentEscaped = Screens.current.screenContent;
  content = unescape(htmlContentEscaped);
  if (screenName === "Login") {
    el = $(content);
    el.addClass("ScreenContent" + screenName);
    $("body").append(el);
  } else {
    if (globalWindowManager === null) {
      globalWindowManager = new WindowManager("#main-container");
    }
    globalWindowManager.setContent(("<div id='" + (Screens.current.classid.replace('#', '')) + "' class='ScreenContent" + screenName + "'>") + content + "</div>");
  }
  return true;
};

doLoadDependencies = function(depList) {
  return new Promise(function(resolve, reject) {
    var url;
    if ((depList == null) || (depList.length == null) || depList.length === 0) {
      resolve(true);
      return;
    }
    url = depList.shift();
    return doLoadScript(url).then((function(_this) {
      return function() {
        return doLoadDependencies(depList);
      };
    })(this)).then((function(_this) {
      return function() {
        return resolve(true);
      };
    })(this));
  });
};

doLoadView = function(viewName) {
  var className;
  className = "View" + viewName;
  if (Views[viewName] != null) {
    return Views[viewName];
  }
  return Views[viewName] = new Promise(function(resolve, reject) {
    return doLoadScript("/views/View" + viewName + ".js").then(function() {
      var depList, view;
      if (window[className] != null) {
        view = new window[className];
        depList = view.getDependencyList();
        return doLoadDependencies(depList).then(function() {
          return resolve(view);
        });
      } else {
        return console.log("Unable to find view: ", className);
      }
    });
  });
};

doAppendView = function(viewName, holderElement) {
  var appendView;
  appendView = function(className, resolve) {
    var view;
    view = new window[className]();
    view.AddToElement(holderElement);
    return view.once("view_ready", function() {
      return resolve(view);
    });
  };
  return new Promise(function(resolve, reject) {
    var className;
    className = "View" + viewName;
    if (window[className] != null) {
      appendView(className, resolve);
      return;
    }
    if (window.busyLoadingView == null) {
      window.busyLoadingView = {};
    }
    if (window.busyLoadingView[viewName] != null) {
      return new Promise((function(_this) {
        return function(resolve, reject) {
          return window.busyLoadingView[viewName].push(resolve);
        };
      })(this)).then((function(_this) {
        return function() {
          return appendView(className, resolve);
        };
      })(this));
    } else {
      window.busyLoadingView[viewName] = [];
      return doLoadView(viewName).then(function(view) {
        var i, len, r, ref;
        ref = window.busyLoadingView[viewName];
        for (i = 0, len = ref.length; i < len; i++) {
          r = ref[i];
          r();
        }
        delete window.busyLoadingView[viewName];
        return appendView(className, resolve);
      });
    }
  });
};

doPopupView = function(viewName, title, settingsName, w, h) {
  return new Promise(function(resolve, reject) {
    return doLoadView(viewName).then(function(view) {
      view.windowTitle = title;
      view.showPopup(settingsName, w, h);
      return view.once("view_ready", function() {
        view.onSetupButtons();
        return resolve(view);
      });
    });
  });
};

doLoadScreen = function(screenName, optionalArgs) {
  return new Promise(function(resolve, reject) {
    var head, oScript;
    head = document.head || document.getElementsByTagName("head")[0];
    oScript = document.createElement("script");
    oScript.type = "text/javascript";
    oScript.onerror = function(oError) {
      console.log("Script error: ", oError);
      return resolve(false);
    };
    oScript.onload = function() {
      return resolve(true);
    };
    head.appendChild(oScript);
    return oScript.src = "/screens/" + screenName + ".js";
  });
};

showViewAsScreen = function(viewName, optionalArgs) {
  return new Promise((function(_this) {
    return function(resolve, reject) {
      if (!Screens["ViewHolder"] && typeof window["ScreenViewHolder"] !== "function") {
        doLoadScreen("ViewHolder", null).then(function() {
          resolve(showViewAsScreen(viewName, optionalArgs));
          return true;
        });
        return true;
      }
      return doLoadView(viewName).then(function(view) {
        showScreen("ViewHolder", {
          view: view,
          viewName: viewName,
          args: optionalArgs
        });
        view.once("view_ready", function() {
          view.popup = Screens["ViewHolder"];
          return resolve(view);
        });
        return view.showInDiv("ViewHolderContent");
      });
    };
  })(this));
};

showScreen = function(screenName, optionalArgs) {
  var className;
  className = "Screen" + screenName;
  if (!Screens[screenName] && typeof window[className] !== "function") {
    return doLoadScreen(screenName, optionalArgs).then(function(loaded) {
      return doShowScreen(screenName, optionalArgs);
    });
  } else {
    return doShowScreen(screenName, optionalArgs);
  }
};

doShowScreen = function(screenName, optionalArgs) {
  var afterSlash, className, parts;
  $('input').each(function(idx, el) {
    return $(el).blur();
  });
  afterSlash = "";
  if (window.hashHistory == null) {
    window.hashHistory = [];
  }
  if ((document.location.hash != null) && document.location.hash.length > 1) {
    if (/\//.test(document.location.hash)) {
      parts = document.location.hash.split('/', 2);
      afterSlash = parts[1];
    }
    window.hashHistory.push(document.location.hash.replace('#', ''));
  }
  if (screenName.indexOf("/") !== -1) {
    parts = screenName.split("/");
    screenName = parts.shift();
    afterSlash = parts.join("/");
  }
  if (!Screens[screenName]) {
    className = "Screen" + screenName;
    if (typeof window[className] === "function") {
      Screens[screenName] = new window[className];
    } else {
      new ErrorMessageBox("Screen reference error:<br>" + screenName);
      console.log("Error, unknown screen '" + screenName + "'");
      return;
    }
  }
  if (Screens.current !== 0) {
    Screens.history.push(Screens.current);
    Screens.current.onHideScreen();
    $(Screens.current.classid).hide();
  }
  Screens.current = Screens[screenName];
  activateCurrentScreen(optionalArgs, screenName);
};

activateCurrentScreen = function(optionalArgs, screenName) {
  var h, w;
  if (!Screens.current.initialized) {
    Screens.current.onSetupButtons();
    Screens.current.initialized = true;
  }
  doReplaceScreenContent(screenName);
  Screens.current.onResetScreen();
  w = $(window).width();
  h = $(window).height();
  globalTableEvents.emitEvent("resize", [w, h]);
  window.scrollTo(0, 0);
  Screens.current.onShowScreen(optionalArgs);
  $("#MainTitle").html(Screens.current.windowTitle);
  if (Screens.current.windowSubTitle.length > 0) {
    $("#SubTitle").html(Screens.current.windowSubTitle);
    $("#SubTitle").show();
    $("#MainTitle").removeClass("alone");
  } else {
    $("#SubTitle").hide();
    $("#MainTitle").addClass("alone");
  }
  $(Screens.current.classid).show();
};
var Screen,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Screen = (function() {
  var resetAllInputs;

  Screen.prototype.classid = "";

  Screen.prototype.initialized = false;

  Screen.prototype.backButtonText = "";

  Screen.prototype.actionButtonText = "";

  Screen.prototype.windowTitle = "** Unknown screen **";

  Screen.prototype.windowSubTitle = "** windowSubTitle not set **";

  function Screen() {
    this.onSetupButtons = bind(this.onSetupButtons, this);
    this.onResetScreen = bind(this.onResetScreen, this);
    this.onHideScreen = bind(this.onHideScreen, this);
    this.onShowScreen = bind(this.onShowScreen, this);
    this.internalFindElements = bind(this.internalFindElements, this);
    var cssTag;
    this.classid = "#" + this.constructor.name + ".screen";
    if (this.css != null) {
      cssTag = $("<style type='text/css'>" + this.css + "</style>");
      $("head").append(cssTag);
    }
  }

  Screen.prototype.internalFindElements = function(parentTag) {
    var el, id;
    el = $(parentTag);
    id = el.attr("id");
    if (id != null) {
      this[id] = el;
    }
    return el.children().each((function(_this) {
      return function(idx, el) {
        return _this.internalFindElements(el);
      };
    })(this));
  };

  Screen.prototype.onShowScreen = function() {
    return this.screenHidden = false;
  };

  Screen.prototype.onHideScreen = function() {
    return this.screenHidden = true;
  };

  Screen.prototype.onResetScreen = function() {
    var el, i, len, ref;
    ref = $(this.classid);
    for (i = 0, len = ref.length; i < len; i++) {
      el = ref[i];
      this.internalFindElements(el);
      true;
    }
    return true;
  };

  Screen.prototype.onSetupButtons = function() {};

  resetAllInputs = function() {
    $("input[type=text], textarea").val("");
    return $("input[type=number], textarea").val("");
  };

  return Screen;

})();

/*

A View is a managed class that contains Javascript, and HTML Template, and a CSS file
The base view code is loaded on demand from the server.   Something should extend this
base view class to implement specific actions.

The base class handles adding the CSS to the document, adding the HTML template to the
DOM and setting up variables based on the template.

from showPopup:
@property elHolder [jQUery]         Contains the holder element
@property popup    [PopupWindow]    Popup window object from Ninja
@property gid      [text]           A unique ID used as the elHolder id
 */
var View,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

View = (function() {
  var resetAllInputs;

  View.prototype.windowTitle = "** Unknown View **";

  function View() {
    this.onResetScreen = bind(this.onResetScreen, this);
    this.onResize = bind(this.onResize, this);
    this.onHideScreen = bind(this.onHideScreen, this);
    this.onShowScreen = bind(this.onShowScreen, this);
    this.internalFindElements = bind(this.internalFindElements, this);
    this.showPopup = bind(this.showPopup, this);
    this.showInDiv = bind(this.showInDiv, this);
    this.closePopup = bind(this.closePopup, this);
    this.AddToElement = bind(this.AddToElement, this);
    this.addToolbar = bind(this.addToolbar, this);
    this.gid = GlobalValueManager.NextGlobalID();
    $(this.classid).each((function(_this) {
      return function(idx, el) {
        _this.internalFindElements(el);
        return true;
      };
    })(this));
    GlobalClassTools.addEventManager(this);
    globalTableEvents.on("resize", this.onResize);
  }

  View.prototype.getDependencyList = function() {
    return null;
  };

  View.prototype.addToolbar = function(buttonList) {
    if (this.popup != null) {
      this.popup.addToolbar(buttonList);
    } else {
      console.log("Can't add toolbar to non poup view");
    }
  };

  View.prototype.AddToElement = function(holderElement) {
    var cssTag;
    this.elHolder = $(holderElement);
    this.elHolder.addClass(this.constructor.name);
    this.elHolder.html(this.template);
    cssTag = $("<style>" + this.css + "</style>");
    $("head").append(cssTag);
    this.internalFindElements(this.elHolder);
    this.onShowScreen();
    return setTimeout((function(_this) {
      return function() {
        return _this.emitEvent("view_ready", []);
      };
    })(this), 1);
  };

  View.prototype.closePopup = function() {
    this.popup.destroy();
    return delete this.popup;
  };

  View.prototype.showInDiv = function(elTarget) {
    var cssTag;
    if (typeof elTarget === "string") {
      this.elHolder = $("#" + elTarget.replace("#", ""));
    } else {
      this.elHolder = $(elTarget);
    }
    $(document).ready((function(_this) {
      return function() {
        _this.internalFindElements(_this.elHolder);
        _this.onShowScreen();
        return _this.emitEvent("view_ready", []);
      };
    })(this));
    this.elHolder.addClass("viewHolder");
    this.elHolder.html(this.template);
    if ((this.css != null) && this.css.length > 0) {
      cssTag = $("<style>" + this.css + "</style>");
      $("head").append(cssTag);
    }
    return true;
  };

  View.prototype.showPopup = function(optionalName, w, h) {
    var cssTag, scrollX, scrollY, x, y;
    if (w == null) {
      w = $(window).width() - 100;
    }
    if (h == null) {
      h = $(window).height() - 100;
    }
    scrollX = window.pageXOffset || document.body.scrollLeft;
    scrollY = window.pageYOffset || document.body.scrollTop;
    x = ($(window).width() - w) / 2 + scrollX;
    y = ($(window).height() - h) / 2 + scrollY;
    y -= 34 / 2;
    this.popup = new PopupWindow(this.windowTitle, x, y, {
      tableName: optionalName,
      w: w,
      h: h
    });
    this.gid = "View" + GlobalValueManager.NextGlobalID();
    this.elHolder = $("<div />", {
      id: this.gid,
      "class": "popupView " + this.constructor.name
    });
    $(document).ready((function(_this) {
      return function() {
        _this.internalFindElements(_this.elHolder);
        _this.onShowScreen();
        return _this.emitEvent("view_ready", []);
      };
    })(this));
    this.elHolder.html(this.template);
    this.popup.windowScroll.append(this.elHolder);
    cssTag = $("<style>" + this.css + "</style>");
    $("head").append(cssTag);
    return true;
  };

  View.prototype.internalFindElements = function(parentTag) {
    var el, id;
    el = $(parentTag);
    id = el.attr("id");
    if (id != null) {
      this[id] = el;
    }
    return el.children().each((function(_this) {
      return function(idx, el) {
        return _this.internalFindElements(el);
      };
    })(this));
  };

  View.prototype.onShowScreen = function() {
    return this.screenHidden = false;
  };

  View.prototype.onHideScreen = function() {
    return this.screenHidden = true;
  };

  View.prototype.onResize = function(a, b) {
    var h, w;
    w = 0;
    h = 0;
    if (this.elHolder != null) {
      w = this.elHolder.width();
      h = this.elHolder.height();
    }
    return this.emitEvent("resize", [w, h]);
  };

  View.prototype.onResetScreen = function() {
    return Screen.resetAllInputs();
  };

  resetAllInputs = function() {
    $("input[type=text], textarea").val("");
    return $("input[type=number], textarea").val("");
  };

  return View;

})();
var WindowManager,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

WindowManager = (function() {
  WindowManager.prototype.allowHorizontalScroll = false;

  function WindowManager(holderElement) {
    this.setScrollable = bind(this.setScrollable, this);
    this.onResizeHolder = bind(this.onResizeHolder, this);
    this.onResizeContent = bind(this.onResizeContent, this);
    this.onResizeContent2 = bind(this.onResizeContent2, this);
    this.elWindowManagerOutside = new WidgetTag("div", "windowManager outside");
    this.elToolbar = this.elWindowManagerOutside.addDiv("toolbar");
    this.elContent = this.elWindowManagerOutside.addDiv("windowcontent");
    if (typeof holderElement === "string") {
      this.elHolder = $("#" + holderElement.replace("#", ""));
    } else if (typeof holderElement === "object" && (holderElement.el != null)) {
      this.elHolder = holderElement.el;
    } else {
      this.elHolder = $(holderElement);
    }
    this.elHolder.append(this.elWindowManagerOutside.el);
    this.elHolder.on("resize", this.onResizeHolder);
    this.elContent.on("resize", this.onResizeContent);
    this.elWindowManagerOutside.on("resize", this.onResizeContent2);
  }

  WindowManager.prototype.onResizeContent2 = function(e) {
    console.log("WindowManager onResizeContent2:", e);
    return true;
  };

  WindowManager.prototype.onResizeContent = function(e) {
    console.log("WindowManager onResizeContent:", e);
    return true;
  };

  WindowManager.prototype.onResizeHolder = function(e) {
    console.log("WindowManager onResizeHolder:", e);
    return true;
  };

  WindowManager.prototype.setContent = function(html) {
    return this.elContent.html(html);
  };

  WindowManager.prototype.setScrollable = function() {
    this.elScrollable = this.elContent.addDiv("scrollable");
    this.elWindowWrapper = this.elScrollable.addDiv("scrollcontent");
    return this.myScroll = new IScroll(this.elWindowWrapper, {
      mouseWheel: true,
      scrollbars: true,
      bounce: false,
      resizeScrollbars: false,
      freeScroll: this.allowHorizontalScroll,
      scrollX: this.allowHorizontalScroll
    });
  };

  return WindowManager;

})();
var TableViewColBase, reDate1, reDate2, reDecimal, reNumber,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

reDate1 = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T00.00.00.000Z/;

reDate2 = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T[0-9][0-9].[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9]Z/;

reNumber = /^[\-1-9][0-9]{1,10}$/;

reDecimal = /^[\-1-9\.][0-9\.]{1,11}\.[0-9]+$/;

TableViewColBase = (function() {
  function TableViewColBase() {
    this.deserialize = bind(this.deserialize, this);
    this.serialize = bind(this.serialize, this);
    this.deduceInitialColumnType = bind(this.deduceInitialColumnType, this);
    this.deduceColumnType = bind(this.deduceColumnType, this);
    this.renderTooltip = bind(this.renderTooltip, this);
    this.getRenderFunction = bind(this.getRenderFunction, this);
    this.changeColumn = bind(this.changeColumn, this);
    this.renderValue = bind(this.renderValue, this);
    this.getIsCalculation = bind(this.getIsCalculation, this);
    this.getAutoSize = bind(this.getAutoSize, this);
    this.getSystemColumn = bind(this.getSystemColumn, this);
    this.getAlwaysHidden = bind(this.getAlwaysHidden, this);
    this.getRequired = bind(this.getRequired, this);
    this.onFocus = bind(this.onFocus, this);
    this.getFormatterName = bind(this.getFormatterName, this);
    this.getFormatter = bind(this.getFormatter, this);
    this.getType = bind(this.getType, this);
    this.RenderHeaderHorizontal = bind(this.RenderHeaderHorizontal, this);
    this.RenderHeader = bind(this.RenderHeader, this);
    this.getWidth = bind(this.getWidth, this);
  }

  TableViewColBase.prototype.getName = function() {
    return "No name";
  };

  TableViewColBase.prototype.getSource = function() {
    return "";
  };

  TableViewColBase.prototype.getOrder = function() {
    return 999;
  };

  TableViewColBase.prototype.getOptions = function() {
    return null;
  };

  TableViewColBase.prototype.getClickable = function() {
    return false;
  };

  TableViewColBase.prototype.getEditable = function() {
    return false;
  };

  TableViewColBase.prototype.getAlign = function() {
    return null;
  };

  TableViewColBase.prototype.getWidth = function() {
    return 0;
  };

  TableViewColBase.prototype.RenderHeader = function(parent, location) {
    return parent.html("No RenderHeader");
  };

  TableViewColBase.prototype.RenderHeaderHorizontal = function(parent, location) {
    return parent.html("No RenderHeaderHorizontal");
  };

  TableViewColBase.prototype.UpdateSortIcon = function(newSort) {
    return null;
  };

  TableViewColBase.prototype.getVisible = function() {
    return true;
  };

  TableViewColBase.prototype.getType = function() {
    return "text";
  };

  TableViewColBase.prototype.getFormatter = function() {
    if (this.formatter) {
      return this.formatter;
    }
    return this.formatter = globalDataFormatter.getFormatter(this.getType());
  };

  TableViewColBase.prototype.getFormatterName = function() {
    var f;
    f = this.getFormatter();
    if (f != null) {
      return f.name;
    }
    return null;
  };

  TableViewColBase.prototype.onFocus = function(e, col, data) {
    var f;
    f = this.getFormatter();
    if ((f != null) && (f.onFocus != null)) {
      f.onFocus(e, col, data);
    }
    return true;
  };

  TableViewColBase.prototype.getRequired = function() {
    return false;
  };

  TableViewColBase.prototype.getAlwaysHidden = function() {
    return false;
  };

  TableViewColBase.prototype.getSystemColumn = function() {
    return false;
  };

  TableViewColBase.prototype.getAutoSize = function() {
    return false;
  };

  TableViewColBase.prototype.getIsCalculation = function() {
    return false;
  };

  TableViewColBase.prototype.renderValue = function(value, keyValue, row) {
    return value;
  };

  TableViewColBase.prototype.changeColumn = function(varName, value) {
    return true;
  };

  TableViewColBase.prototype.getRenderFunction = function() {
    return null;
  };

  TableViewColBase.prototype.renderTooltip = function(row, value, tooltipWindow) {
    return false;
  };

  TableViewColBase.prototype.deduceColumnType = function(newData) {
    return null;
  };

  TableViewColBase.prototype.deduceInitialColumnType = function() {
    return null;
  };

  TableViewColBase.prototype.serialize = function() {
    var obj;
    obj = {};
    obj.name = this.getName();
    obj.type = this.getType();
    obj.width = this.getWidth();
    obj.options = this.getOptions();
    obj.editable = this.getEditable();
    obj.visible = this.getVisible();
    obj.clickable = this.getClickable();
    obj.align = this.getAlign();
    obj.source = this.getSource();
    obj.required = this.getRequired();
    obj.hideable = this.getAlwaysHidden();
    obj.system = this.getSystemColumn();
    obj.autosize = this.getAutoSize();
    obj.order = this.getOrder();
    obj.render = this.getRenderFunction();
    obj.calculate = this.getIsCalculation();
    if ((this.data.render != null) && typeof this.data.render === "string" && this.data.render.charAt(0) === '=') {
      obj.render = this.data.render;
    }
    return obj;
  };

  TableViewColBase.prototype.deserialize = function(obj) {
    var value, varName;
    for (varName in obj) {
      value = obj[varName];
      this.changeColumn(varName, value);
    }
    return true;
  };

  return TableViewColBase;

})();

/*

 Class:  TableView
 =====================================================================================

 This is a multi-purpose table view that handles many aspects of a fast display and
 edit table/grid.

 @example:
 new TableView $(".tableHolder")

 Events:
 =====================================================================================

 "click_col" : will trigger when a row is clicked with the name "col", for example
 @example: table.on "click_zipcode", (row, e) =>
 */
var TableView, globalKeyboardEvents, globalTableAdmin, globalTableEvents, minHeightOfTable,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  slice = [].slice;

globalKeyboardEvents = new EvEmitter();

globalTableEvents = new EvEmitter();

globalTableAdmin = true;

minHeightOfTable = 400;

$(window).on("resize", (function(_this) {
  return function(e) {
    var h, w;
    w = $(window).width();
    h = $(window).height();
    return globalTableEvents.emitEvent("resize", [w, h]);
  };
})(this));

$(document).on("keyup", (function(_this) {
  return function(e) {
    if (e.target === document.body) {
      if (e.keyCode === 38) {
        globalKeyboardEvents.emitEvent("up", [e]);
      } else if (e.keyCode === 40) {
        globalKeyboardEvents.emitEvent("down", [e]);
      } else if (e.keyCode === 37) {
        globalKeyboardEvents.emitEvent("left", [e]);
      } else if (e.keyCode === 39) {
        globalKeyboardEvents.emitEvent("right", [e]);
      } else if (e.keyCode === 9) {
        globalKeyboardEvents.emitEvent("tab", [e]);
      } else if (e.keyCode === 13) {
        globalKeyboardEvents.emitEvent("enter", [e]);
      } else if (e.keyCode === 27) {
        globalKeyboardEvents.emitEvent("esc", [e]);
      }
    }
    return true;
  };
})(this));

$(document).on("mousedown", (function(_this) {
  return function(e) {
    globalKeyboardEvents.emitEvent("global_mouse_down", [e]);
    return true;
  };
})(this));

TableView = (function() {
  TableView.SORT_ASC = 1;

  TableView.SORT_DESC = -1;

  TableView.SORT_NONE = 0;

  TableView.prototype.imgChecked = "<img src='/images/checkbox.png' width='16' height='16' alt='Selected' />";

  TableView.prototype.imgNotChecked = "<img src='/images/checkbox_no.png' width='16' height='16' alt='Selected' />";

  TableView.prototype.defaultRowClick = function(row, e) {
    return false;
  };

  TableView.prototype.onSetCheckbox = function(checkbox_key, value) {
    return console.log("onSetCheckbox(", checkbox_key, ",", value, ")");
  };

  TableView.prototype.onConfigureColumns = function(coords) {
    var popup;
    popup = new PopupWindowTableConfiguration("Configure Columns", coords.x - 150, coords.y);
    return popup.show(this);
  };

  TableView.prototype.numberChecked = function() {
    return Object.keys(this.rowDataSelected).length;
  };

  function TableView(elTableHolder, showCheckboxes) {
    this.elTableHolder = elTableHolder;
    this.showCheckboxes = showCheckboxes;
    this.ungroupColumn = bind(this.ungroupColumn, this);
    this.getColumnType = bind(this.getColumnType, this);
    this.findRowFromPath = bind(this.findRowFromPath, this);
    this.findColFromPath = bind(this.findColFromPath, this);
    this.destroy = bind(this.destroy, this);
    this.hide = bind(this.hide, this);
    this.show = bind(this.show, this);
    this.findPathVisible = bind(this.findPathVisible, this);
    this.setFocusCell = bind(this.setFocusCell, this);
    this.onActionCopyCell = bind(this.onActionCopyCell, this);
    this.setFocusFirstCell = bind(this.setFocusFirstCell, this);
    this.moveCellDown = bind(this.moveCellDown, this);
    this.moveCellUp = bind(this.moveCellUp, this);
    this.moveCellLeft = bind(this.moveCellLeft, this);
    this.moveCellRight = bind(this.moveCellRight, this);
    this.onAddedEvent = bind(this.onAddedEvent, this);
    this.reset = bind(this.reset, this);
    this.clear = bind(this.clear, this);
    this.addMessageRow = bind(this.addMessageRow, this);
    this.onFilterKeypress = bind(this.onFilterKeypress, this);
    this.groupBy = bind(this.groupBy, this);
    this.sortByColumn = bind(this.sortByColumn, this);
    this.real_render = bind(this.real_render, this);
    this.render = bind(this.render, this);
    this.updateStatusText = bind(this.updateStatusText, this);
    this.layoutShadow = bind(this.layoutShadow, this);
    this.setAutoFillWidth = bind(this.setAutoFillWidth, this);
    this.findBestFit = bind(this.findBestFit, this);
    this.isColumnEmpty = bind(this.isColumnEmpty, this);
    this.updateScrollbarSettings = bind(this.updateScrollbarSettings, this);
    this.resetCachedFromSize = bind(this.resetCachedFromSize, this);
    this.resetCachedFromScroll = bind(this.resetCachedFromScroll, this);
    this.updateVisibleText = bind(this.updateVisibleText, this);
    this.updateVisibleTextRow = bind(this.updateVisibleTextRow, this);
    this.updateVisibleActionRow = bind(this.updateVisibleActionRow, this);
    this.updateVisibleActionRowText = bind(this.updateVisibleActionRowText, this);
    this.incrementColumn = bind(this.incrementColumn, this);
    this.updateCellClasses = bind(this.updateCellClasses, this);
    this.initializeSpacerCell = bind(this.initializeSpacerCell, this);
    this.isResizable = bind(this.isResizable, this);
    this.isHeaderCell = bind(this.isHeaderCell, this);
    this.getCellType = bind(this.getCellType, this);
    this.getRowType = bind(this.getRowType, this);
    this.shouldSkipCol = bind(this.shouldSkipCol, this);
    this.setDataField = bind(this.setDataField, this);
    this.setHeaderGroupField = bind(this.setHeaderGroupField, this);
    this.setHeaderField = bind(this.setHeaderField, this);
    this.setHeaderFilterField = bind(this.setHeaderFilterField, this);
    this.getCellDataPath = bind(this.getCellDataPath, this);
    this.shouldAdvanceCol = bind(this.shouldAdvanceCol, this);
    this.getCellFormatterName = bind(this.getCellFormatterName, this);
    this.getCellRecordID = bind(this.getCellRecordID, this);
    this.getCellSource = bind(this.getCellSource, this);
    this.getCellTablename = bind(this.getCellTablename, this);
    this.getCellAlign = bind(this.getCellAlign, this);
    this.getCellGroupNumber = bind(this.getCellGroupNumber, this);
    this.getCellStriped = bind(this.getCellStriped, this);
    this.getCellClickable = bind(this.getCellClickable, this);
    this.getCellEditable = bind(this.getCellEditable, this);
    this.getRowHeight = bind(this.getRowHeight, this);
    this.getColWidth = bind(this.getColWidth, this);
    this.getTableVisibleCols = bind(this.getTableVisibleCols, this);
    this.getTableMaxVisibleCols = bind(this.getTableMaxVisibleCols, this);
    this.getTableVisibleRows = bind(this.getTableVisibleRows, this);
    this.getTableMaxVisibleRows = bind(this.getTableMaxVisibleRows, this);
    this.getTableVisibleHeight = bind(this.getTableVisibleHeight, this);
    this.getTableVisibleWidth = bind(this.getTableVisibleWidth, this);
    this.getTableTotalCols = bind(this.getTableTotalCols, this);
    this.getTableTotalRows = bind(this.getTableTotalRows, this);
    this.getTotalActionWidth = bind(this.getTotalActionWidth, this);
    this.updateFixedPosition = bind(this.updateFixedPosition, this);
    this.setHolderToBottom = bind(this.setHolderToBottom, this);
    this.isVisible = bind(this.isVisible, this);
    this.setStatusBarEnabled = bind(this.setStatusBarEnabled, this);
    this.updateRowData = bind(this.updateRowData, this);
    this.updateColumnList = bind(this.updateColumnList, this);
    this.updateFullHeight = bind(this.updateFullHeight, this);
    this.applyFilters = bind(this.applyFilters, this);
    this.applySorting = bind(this.applySorting, this);
    this.addLock = bind(this.addLock, this);
    this.addSortRule = bind(this.addSortRule, this);
    this.setupContextMenu = bind(this.setupContextMenu, this);
    this.onContextMenuHeader = bind(this.onContextMenuHeader, this);
    this.onRearrange = bind(this.onRearrange, this);
    this.contextMenuChangeType = bind(this.contextMenuChangeType, this);
    this.onRenameField = bind(this.onRenameField, this);
    this.onResize = bind(this.onResize, this);
    this.onContextMenuGroup = bind(this.onContextMenuGroup, this);
    this.onContextMenuData = bind(this.onContextMenuData, this);
    this.onCopyToClipboard = bind(this.onCopyToClipboard, this);
    this.internalSetupMouseEvents = bind(this.internalSetupMouseEvents, this);
    this.onMouseMove = bind(this.onMouseMove, this);
    this.onMouseOut = bind(this.onMouseOut, this);
    this.onMouseHover = bind(this.onMouseHover, this);
    this.onColumnResizeFinished = bind(this.onColumnResizeFinished, this);
    this.onColumnResizeDrag = bind(this.onColumnResizeDrag, this);
    this.pressEnter = bind(this.pressEnter, this);
    this.setColumnFilterAsPopup = bind(this.setColumnFilterAsPopup, this);
    this.onGlobalMouseDown = bind(this.onGlobalMouseDown, this);
    this.onGlobalDataChange = bind(this.onGlobalDataChange, this);
    this.onGlobalTableChange = bind(this.onGlobalTableChange, this);
    this.onGlobalNewData = bind(this.onGlobalNewData, this);
    this.scrollRight = bind(this.scrollRight, this);
    this.scrollUp = bind(this.scrollUp, this);
    this.toggleRowSelected = bind(this.toggleRowSelected, this);
    this.getRowLocked = bind(this.getRowLocked, this);
    this.getRowSelected = bind(this.getRowSelected, this);
    this.resetChecked = bind(this.resetChecked, this);
    this.openSimpleObject = bind(this.openSimpleObject, this);
    this.onClickSimpleObject = bind(this.onClickSimpleObject, this);
    this.setFixedHeaderAndScrollable = bind(this.setFixedHeaderAndScrollable, this);
    this.setFixedSize = bind(this.setFixedSize, this);
    this.setSimpleAndFixed = bind(this.setSimpleAndFixed, this);
    this.setTableCacheName = bind(this.setTableCacheName, this);
    this.addActionColumn = bind(this.addActionColumn, this);
    this.moveActionColumn = bind(this.moveActionColumn, this);
    this.findColumn = bind(this.findColumn, this);
    this.addTable = bind(this.addTable, this);
    this.numberChecked = bind(this.numberChecked, this);
    this.onConfigureColumns = bind(this.onConfigureColumns, this);
    this.onSetCheckbox = bind(this.onSetCheckbox, this);
    this.defaultRowClick = bind(this.defaultRowClick, this);
    GlobalClassTools.addEventManager(this);
    this.colList = [];
    this.actionColList = [];
    this.rowDataRaw = [];
    this.rowDataSelected = {};
    this.showHeaders = true;
    this.showFilters = true;
    this.allowSelectCell = true;
    this.showResize = true;
    this.showConfigTable = true;
    this.enableMouseOver = false;
    this.currentFilters = {};
    this.currentGroups = [];
    this.sortRules = [];
    this.lockList = {};
    this.showGroupPadding = false;
    this.groupPaddingWidth = 10;
    this.contextMenuCallbackFunction = 0;
    this.contextMenuCallSetup = 0;
    this.checkboxLimit = 1;
    this.renderRequired = true;
    if (this.showCheckboxes == null) {
      this.showCheckboxes = false;
    }
    if (!this.elTableHolder[0]) {
      console.log("Error: Table id " + this.elTableHolder + " doesn't exist for " + this.primaryTableName);
      return;
    }
    this.offsetShowingTop = 0;
    this.offsetShowingLeft = 0;
    this.dataCellHeight = 24;
    this.headerCellHeight = 24;
    this.filterCellHeight = 20;
    this.on("added_event", this.onAddedEvent);
    globalKeyboardEvents.on("up", this.moveCellUp);
    globalKeyboardEvents.on("down", this.moveCellDown);
    globalKeyboardEvents.on("left", this.moveCellLeft);
    globalKeyboardEvents.on("right", this.moveCellRight);
    globalKeyboardEvents.on("tab", this.moveCellRight);
    globalKeyboardEvents.on("enter", this.pressEnter);
    globalKeyboardEvents.on("global_mouse_down", this.onGlobalMouseDown);
    globalKeyboardEvents.on("change", this.onGlobalDataChange);
    globalTableEvents.on("table_change", this.onGlobalTableChange);
    globalTableEvents.on("resize", this.onResize);
    window.addEventListener("new_data", this.onGlobalNewData, false);
    if (this.gid == null) {
      this.gid = GlobalValueManager.NextGlobalID();
    }
  }

  TableView.prototype.addTable = function(tableName, columnReduceFunction, overallReduceFunction) {
    this.columnReduceFunction = columnReduceFunction;
    this.overallReduceFunction = overallReduceFunction;
    this.primaryTableName = tableName;
    return true;
  };

  TableView.prototype.findColumn = function(source) {
    var c, j, len1, ref;
    ref = this.colList;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      c = ref[j];
      if (c.getSource() === source) {
        return c;
      }
    }
  };

  TableView.prototype.moveActionColumn = function(sourceName) {
    var col, columns, found, j, len1, newList;
    found = false;
    newList = [];
    columns = DataMap.getColumnsFromTable(this.primaryTableName, null);
    for (j = 0, len1 = columns.length; j < len1; j++) {
      col = columns[j];
      if (col.getSource() === sourceName) {
        this.actionColList.push(col);
      }
    }
    return true;
  };

  TableView.prototype.addActionColumn = function(options) {
    var button, config;
    config = {
      name: "",
      render: null,
      width: 100,
      callback: null,
      source: null,
      tableName: this.primaryTableName
    };
    $.extend(config, options);
    console.log("AddActionColumn:", config);
    button = new TableViewColButton(this.primaryTableName, config.name);
    button.width = config.width;
    button.actualWidth = config.width;
    if (config.render != null) {
      button.render = config.render;
    }
    button.source = config.source;
    this.actionColList.push(button);
    if (config.callback != null) {
      this.on("click_" + (button.getSource()), config.callback);
    }
    return true;
  };

  TableView.prototype.setTableCacheName = function(tableCacheName) {
    this.tableCacheName = tableCacheName;
  };

  TableView.prototype.setSimpleAndFixed = function() {
    this.showFilters = false;
    this.showHeaders = false;
    return this.fixedHeader = true;
  };

  TableView.prototype.setFixedSize = function(w, h) {
    this.fixedWidth = w;
    this.fixedHeight = h;
    this.showFilters = false;
    this.fixedHeight = true;
    this.showHeaders = true;
    this.elTableHolder.width(w);
    this.elTableHolder.height(h);
    this.elTableHolder.find('.table-header .tableview').width(this.elTableHolder.find('.table-body .tableview').width());
    return this.resetCachedFromSize();
  };

  TableView.prototype.setFixedHeaderAndScrollable = function(fixedHeader) {
    this.fixedHeader = fixedHeader != null ? fixedHeader : true;
    return $(window).on('resize', (function(_this) {
      return function() {
        _this.elTableHolder.find('.table-header .tableview').width(_this.elTableHolder.find('.table-body .tableview').width());
        _this.cachedVisibleWidth = null;
        return _this.cachedVisibleHeight = null;
      };
    })(this));
  };

  TableView.prototype.onClickSimpleObject = function(row, e) {
    var coords, data;
    coords = GlobalValueManager.GetCoordsFromEvent(e);
    data = $(e.target).data();
    if (data.path != null) {
      this.openSimpleObject(data.path);
    }
    return true;
  };

  TableView.prototype.openSimpleObject = function(path, coords) {
    return coords = GlobalValueManager.GetCoordsFromEvent(e);
  };

  TableView.prototype.resetChecked = function() {
    return false;
  };

  TableView.prototype.getRowSelected = function(id) {
    var val;
    val = DataMap.getDataField(this.primaryTableName, id, "row_selected");
    if ((val != null) && val === true) {
      return true;
    }
    return false;
  };

  TableView.prototype.getRowLocked = function(id) {
    if (this.lockList[id] != null) {
      return true;
    }
    return false;
  };

  TableView.prototype.toggleRowSelected = function(row) {
    var id, j, len1, newVal, ref, val;
    if (this.getRowLocked(row.id)) {
      return false;
    }
    val = this.getRowSelected(row.id);
    newVal = val === false;
    if (val) {
      globalTableEvents.emitEvent("row_selected", [this.primaryTableName, row.id, false]);
      row.row_selected = false;
      DataMap.getDataMap().updatePathValueEvent("/" + this.primaryTableName + "/" + row.id + "/row_selected", false);
      delete this.rowDataSelected[row.id];
    } else {
      if (this.checkboxLimit === 1) {
        ref = Object.keys(this.rowDataSelected);
        for (j = 0, len1 = ref.length; j < len1; j++) {
          id = ref[j];
          globalTableEvents.emitEvent("row_selected", [this.primaryTableName, row.id, false]);
          DataMap.getDataMap().updatePathValueEvent("/" + this.primaryTableName + "/" + id + "/row_selected", false);
        }
        this.rowDataSelected = {};
      }
      console.log("Setting /" + this.primaryTableName + "/" + row.id + "/row_selected = true");
      DataMap.getDataMap().updatePathValueEvent("/" + this.primaryTableName + "/" + row.id + "/row_selected", true);
      globalTableEvents.emitEvent("row_selected", [this.primaryTableName, row.id, true]);
      this.rowDataSelected[row.id] = true;
    }
    this.resetChecked();
    return true;
  };

  TableView.prototype.scrollUp = function(amount) {
    this.offsetShowingTop += amount;
    this.resetCachedFromScroll();
    return true;
  };

  TableView.prototype.scrollRight = function(amount) {
    this.offsetShowingLeft += amount;
    this.resetCachedFromSize();
    return true;
  };

  TableView.prototype.onGlobalNewData = function(e) {
    if ((e == null) || e.detail.tablename === this.primaryTableName) {
      if (this.resetTimer != null) {
        clearTimeout(this.resetTimer);
      }
      return this.resetTimer = setTimeout((function(_this) {
        return function() {
          delete _this.resetTimer;
          _this.updateRowData();
          _this.resetCachedFromSize();
          return _this.onResize();
        };
      })(this), 50);
    }
  };

  TableView.prototype.onGlobalTableChange = function(tableName, sourceName, field, newValue) {
    if (tableName === this.primaryTableName) {
      this.onGlobalNewData(null);
    }
    return true;
  };

  TableView.prototype.onGlobalDataChange = function(path, newData) {
    var cell;
    cell = this.findPathVisible(path);
    if (cell !== null) {
      this.updateVisibleText();
    }
    return true;
  };

  TableView.prototype.onGlobalMouseDown = function(e) {
    return this.setFocusCell(null, null);
  };

  TableView.prototype.setColumnFilterAsPopup = function(sourceName) {};

  TableView.prototype.pressEnter = function(e) {
    var c, fieldName, j, k, len1, len2, parts, path, record_id, ref, ref1, row, tableName;
    if ((this.currentFocusCell != null) && (this.currentFocusPath == null)) {
      this.setFocusCell(this.currentFocusRow, this.currentFocusCol, e);
      return false;
    }
    if ((this.currentFocusCell == null) || (this.currentFocusPath == null)) {
      return false;
    }
    if (e.path != null) {
      this.currentFocusPath = e.path;
    }
    parts = this.currentFocusPath.split("/");
    tableName = parts[1];
    record_id = parts[2];
    fieldName = parts[3];
    path = this.currentFocusPath;
    ref = this.rowDataRaw;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      row = ref[j];
      if (row.id == null) {
        continue;
      }
      if (row.id.toString() === record_id) {
        ref1 = this.colList;
        for (k = 0, len2 = ref1.length; k < len2; k++) {
          c = ref1[k];
          row[c.getSource()] = DataMap.getDataField(c.tableName, row.id, c.getSource());
          if (c.getSource() === fieldName) {
            if (c.getEditable()) {
              this.currentFocusPath = null;
              DataMap.getDataMap().editValue(path, this.currentFocusCell.el);
            }
          }
        }
        this.emitEvent("click_" + fieldName, [row, e]);
        this.emitEvent("click_row", [row, e]);
      }
    }
    return true;
  };

  TableView.prototype.onColumnResizeDrag = function(diffX, diffY, e) {
    var col, newWidth, source;
    source = this.colByNum[this.resizingColumn].getSource();
    col = this.findColumn(source);
    newWidth = this.resizingBefore + diffX;
    if (newWidth < 10) {
      newWidth = 10;
    }
    if (newWidth > 800) {
      newWidth = 800;
    }
    col.changeColumn("width", newWidth);
    this.resetCachedFromSize();
    this.updateVisibleText();
    return true;
  };

  TableView.prototype.onColumnResizeFinished = function(diffX, diffY, e) {
    var col, newWidth, source;
    source = this.colByNum[this.resizingColumn].getSource();
    col = this.findColumn(source);
    newWidth = this.resizingBefore + diffX;
    if (newWidth < 10) {
      newWidth = 10;
    }
    if (newWidth > 800) {
      newWidth = 800;
    }
    DataMap.changeColumnAttribute(col.tableName, col.getSource(), "width", newWidth);
    delete this.resizingColumn;
    return true;
  };

  TableView.prototype.onMouseHover = function(e) {
    var c, col, coords, j, len1, ref, result, results, row, w;
    coords = GlobalValueManager.GetCoordsFromEvent(e);
    if (e.path == null) {
      this.tooltipWindow.hide();
      return;
    }
    this.tooltipShowing = false;
    row = this.findRowFromPath(e.path);
    col = this.findColFromPath(e.path);
    ref = this.colList;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      c = ref[j];
      if (c.getSource() === col) {
        w = this.tooltipWindow.getBodyWidget();
        w.resetClasses("ninjaTooltipBody");
        this.tooltipWindow.floatingWin.addClass("ninjaTooltip");
        if ((row != null) && (row[col] != null)) {
          result = c.renderTooltip(row, row[col], this.tooltipWindow);
          console.log("RESULT=", result, c);
          if (result === true) {
            this.tooltipWindow.moveTo(coords.x - (this.tooltipWindow.width / 2), coords.y - 10 - this.tooltipWindow.height);
            this.tooltipWindow.show();
            results.push(this.tooltipShowing = true);
          } else {
            results.push(void 0);
          }
        } else {
          results.push(void 0);
        }
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  TableView.prototype.onMouseOut = function(e) {
    if ((this.lastMouseMovePath != null) && this.enableMouseOver) {
      this.lastMouseMovePath = null;
      globalTableEvents.emitEvent("mouseover", [this.primaryTableName, null, null, null]);
    }
    if (this.mouseHoverTimer != null) {
      clearTimeout(this.mouseHoverTimer);
      delete this.mouseHoverTimer;
    }
    if ((this.tooltipShowing != null) && this.tooltipShowing === true) {
      this.tooltipShowing = false;
      this.tooltipWindow.hide();
    }
    return true;
  };

  TableView.prototype.onMouseMove = function(e) {
    var col, coords, row;
    if ((e != null) && (e.path != null) && this.enableMouseOver) {
      if (e.path !== this.lastMouseMovePath) {
        row = this.findRowFromPath(e.path);
        col = this.findColFromPath(e.path);
        globalTableEvents.emitEvent("mouseover", [this.primaryTableName, e.path, row, col]);
        this.lastMouseMovePath = e.path;
      }
    }
    if (this.mouseHoverTimer != null) {
      clearTimeout(this.mouseHoverTimer);
    }
    this.mouseHoverTimer = setTimeout(this.onMouseHover, 1000, e);
    if ((this.tooltipShowing != null) && this.tooltipShowing === true) {
      coords = GlobalValueManager.GetCoordsFromEvent(e);
      return this.tooltipWindow.moveTo(coords.x - (this.tooltipWindow.width / 2), coords.y - 10 - this.tooltipWindow.height);
    }
  };

  TableView.prototype.internalSetupMouseEvents = function() {
    this.virtualScrollV.on("scroll_to", (function(_this) {
      return function(amount) {
        _this.offsetShowingTop = amount;
        _this.updateScrollbarSettings();
        _this.resetCachedFromScroll();
        return true;
      };
    })(this));
    this.virtualScrollH.on("scroll_to", (function(_this) {
      return function(amount) {
        _this.offsetShowingLeft = amount;
        _this.updateScrollbarSettings();
        _this.resetCachedFromScroll();
        return true;
      };
    })(this));
    this.elTheTable.on("mouseout", this.onMouseOut);
    this.elTheTable.on("mousemove", this.onMouseMove);
    this.elTheTable.on("mousedown", (function(_this) {
      return function(e) {
        var data;
        globalKeyboardEvents.emitEvent("global_mouse_down", [e]);
        data = WidgetTag.getDataFromEvent(e);
        if ((data.path != null) && data.path === "grab") {
          _this.resizingColumn = data.cn;
          _this.resizingRow = data.rn;
          _this.resizingBefore = _this.colByNum[data.cn].currentWidth;
          return GlobalMouseDrag.startDrag(e, _this.onColumnResizeDrag, _this.onColumnResizeFinished);
        }
        return false;
      };
    })(this));
    return this.elTheTable.on("click touchbegin", (function(_this) {
      return function(e) {
        var col, data, realCol, row;
        if (e.target.className === "dataFilter") {
          console.log("passing");
          $(e.target).focus();
          return false;
        }
        data = WidgetTag.getDataFromEvent(e);
        console.log("elTheTable.on click data=", data);
        if ((data == null) || (data.path == null)) {
          console.log("No path for click", e.path);
          return false;
        }
        row = _this.findRowFromPath(data.path);
        col = _this.findColFromPath(data.path);
        if ((row != null) && (row.id != null)) {
          _this.setFocusCell(data.vr, data.vc, e);
        } else {
          _this.setFocusCell(null);
        }
        if (data.action != null) {
          _this.elTheTable.el.trigger("click_" + data.action, [row, e]);
        }
        if (row == null) {
          return false;
        }
        if (row === "Filter") {
          return false;
        }
        if (row === "Header") {
          _this.sortByColumn(col);
          return false;
        }
        if (col === "row_selected") {
          _this.toggleRowSelected(row);
        } else {
          _this.pressEnter(e);
          realCol = _this.findColumn(col);
          if ((realCol != null) && (realCol.onFocus != null)) {
            realCol.onFocus(e, col, row);
          }
        }
        return false;
      };
    })(this));
  };

  TableView.prototype.onCopyToClipboard = function(e, value) {
    console.log("Copy to clipboard:", value);
    copyToClipboard(value);
    return true;
  };

  TableView.prototype.onContextMenuData = function(e) {
    var aValue, bValue, col, data, popupMenu, row;
    data = WidgetTag.getDataFromEvent(e);
    row = this.findRowFromPath(data.path);
    col = this.findColFromPath(data.path);
    popupMenu = new PopupMenu("Options", e);
    aValue = DataMap.getDataField(this.primaryTableName, row.id, col);
    if (aValue != null) {
      aValue = aValue.toString().trim();
      popupMenu.addItem("Copy '" + aValue + "'", this.onCopyToClipboard, aValue);
    }
    bValue = DataMap.getDataFieldFormatted(this.primaryTableName, row.id, col);
    if ((bValue != null) && bValue !== aValue) {
      popupMenu.addItem("Copy '" + bValue + "'", this.onCopyToClipboard, bValue);
    }
    if (this.showCheckboxes && (row.id != null)) {
      popupMenu.addItem("Copy '" + row.id + "'", this.onCopyToClipboard, row.id);
    }
    return true;
  };

  TableView.prototype.onContextMenuGroup = function(rowNum, coords) {
    var j, len1, popupMenu, ref, source;
    popupMenu = new PopupMenu("Data Grouping", coords.x - 150, coords.y);
    ref = this.currentGroups;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      source = ref[j];
      popupMenu.addItem("Removing " + source, (function(_this) {
        return function(e, source) {
          var k, len2, name, newList, ref1;
          console.log("Remove grouping", source);
          _this.ungroupColumn(source);
          newList = [];
          ref1 = _this.currentGroups;
          for (k = 0, len2 = ref1.length; k < len2; k++) {
            name = ref1[k];
            if (name === source) {
              continue;
            }
            newList.push(name);
          }
          _this.currentGroups = newList;
          _this.updateRowData();
          return _this.updateVisibleText();
        };
      })(this), source);
    }
    return true;
  };

  TableView.prototype.onResize = function() {
    if (!this.isVisible()) {
      return;
    }
    this.cachedVisibleWidth = null;
    this.cachedVisibleHeight = null;
    this.cachedTotalVisibleCols = null;
    this.cachedTotalVisibleRows = null;
    if ((this.fixedWidth != null) && (this.fixedHeight != null)) {
      this.elTableHolder.width(this.fixedWidth);
      this.elTableHolder.height(this.fixedHeight);
    } else if (this.elTableHolder.width() > 0) {
      this.updateFixedPosition();
    }
    this.updateRowData();
    return true;
  };

  TableView.prototype.onRenameField = function(source) {
    var col, j, len1, m, ref, results;
    ref = this.colList;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      col = ref[j];
      if (col.getSource() === source) {
        m = new ModalDialog({
          showOnCreate: false,
          content: "Enter a new name for this column",
          position: "top",
          title: "Name:",
          ok: "Save"
        });
        m.getForm().addTextInput("input1", "Name", col.getName());
        m.getForm().onSubmit = (function(_this) {
          return function(form) {
            DataMap.changeColumnAttribute(_this.primaryTableName, source, "name", form.input1);
            _this.updateVisibleText();
            return m.hide();
          };
        })(this);
        results.push(m.show());
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  TableView.prototype.contextMenuChangeType = function(source, coords) {
    var j, len1, name, popupMenu, ref;
    popupMenu = new PopupMenu("New Type: " + source, coords.x - 150, coords.y - 200);
    ref = Object.keys(globalDataFormatter.formats);
    for (j = 0, len1 = ref.length; j < len1; j++) {
      name = ref[j];
      popupMenu.addItem(name, (function(_this) {
        return function(e, opt) {
          var col, k, len2, ref1;
          console.log("Change type of " + source + " to " + opt);
          ref1 = _this.colList;
          for (k = 0, len2 = ref1.length; k < len2; k++) {
            col = ref1[k];
            if (col.getSource() === source) {
              DataMap.changeColumnAttribute(col.tableName, source, "type", opt);
              return;
            }
          }
        };
      })(this), name);
    }
    return true;
  };

  TableView.prototype.onRearrange = function(e, source) {
    var m;
    m = new ModalSortItems(this.primaryTableName);
    return true;
  };

  TableView.prototype.onContextMenuHeader = function(source, coords) {
    var col, index, j, len1, popupMenu, ref, ref1;
    console.log("Context on header:", source);
    popupMenu = null;
    ref = this.colByNum;
    for (index in ref) {
      col = ref[index];
      if (col.getSource() === source) {
        popupMenu = new PopupMenu("" + (col.getName()), coords.x - 150, coords.y);
        popupMenu.addItem("Hide column", (function(_this) {
          return function(e, source) {
            DataMap.changeColumnAttribute(_this.primaryTableName, source, "visible", false);
            return _this.updateRowData();
          };
        })(this), source);
        popupMenu.addItem("Group similar values", (function(_this) {
          return function(e, source) {
            return _this.groupBy(source);
          };
        })(this), source);
        popupMenu.addItem("Rearrange Columns", (function(_this) {
          return function(e, source) {
            return _this.onRearrange(e, source);
          };
        })(this), source);
        if (this.showConfigTable) {
          popupMenu.addItem("Rename Column", (function(_this) {
            return function(e, source) {
              _this.onRenameField(source);
              return _this.updateVisibleText();
            };
          })(this), source);
          popupMenu.addItem("Change Column Type", (function(_this) {
            return function(e, source) {
              return setTimeout(function() {
                return _this.contextMenuChangeType(source, coords);
              }, 500);
            };
          })(this), source);
          if (globalTableAdmin) {
            popupMenu.addItem("Open table editor", (function(_this) {
              return function(e, source) {
                var ref1, results;
                ref1 = _this.colByNum;
                results = [];
                for (index in ref1) {
                  col = ref1[index];
                  if (col.getSource() === source) {
                    console.log("Emitting open_editor");
                    results.push(doPopupView("ShowTableEditor", "Editing table: " + _this.primaryTableName, null, 1300, 800).then(function(view) {
                      return view.showTableEditor(_this.primaryTableName);
                    }));
                  } else {
                    results.push(void 0);
                  }
                }
                return results;
              };
            })(this), source);
          }
        }
      }
    }
    if (popupMenu === null) {
      popupMenu = new PopupMenu("Unknown " + source, coords.x - 150, coords.y);
    }
    ref1 = this.colList;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      col = ref1[j];
      if ((col.visible != null) && col.visible === false) {
        popupMenu.addItem("Show " + (col.getName()), (function(_this) {
          return function(e, list) {
            var num, showName;
            showName = list.pop();
            source = list.pop();
            num = _this.findColumn(source).getOrder();
            DataMap.changeColumnAttribute(col.tableName, showName, "visible", true);
            DataMap.changeColumnAttribute(col.tableName, showName, "order", num);
            return setTimeout(function() {
              _this.resetCachedFromSize();
              return _this.updateVisibleText();
            }, 200);
          };
        })(this), [source, col.getSource()]);
      }
    }
    return false;
  };

  TableView.prototype.setupContextMenu = function(contextMenuCallbackFunction) {
    this.contextMenuCallbackFunction = contextMenuCallbackFunction;
    if (this.contextMenuCallSetup === 1) {
      return true;
    }
    this.contextMenuCallSetup = 1;
    this.elTableHolder.bind("contextmenu", (function(_this) {
      return function(e) {
        var data, m;
        data = WidgetTag.getDataFromEvent(e);
        console.log("Context Menu:", data);
        if (data.path == null) {
          return false;
        }
        if (m = data.path.match(/^.group.([0-9]+)/)) {
          _this.onContextMenuGroup(parseInt(m[1]), data.coords);
          return false;
        }
        if (m = data.path.match(/^.*Header[^a-zA-Z](.*)/)) {
          _this.onContextMenuHeader(m[1], data.coords);
          return false;
        }
        console.log("Context menu for " + data.path);
        _this.onContextMenuData(e);
        return false;
      };
    })(this));
    return true;
  };

  TableView.prototype.addSortRule = function(sourceName, sortMode) {
    var found, j, len1, ref, rule;
    found = null;
    ref = this.sortRules;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      rule = ref[j];
      if (rule.source === sourceName) {
        found = rule;
        break;
      }
    }
    if (found === null) {
      found = {
        source: sourceName,
        tableName: this.primaryTableName,
        state: 0
      };
      this.sortRules = [found];
    }
    if ((sortMode != null) && sortMode === 0) {
      found.state = found.state * -1;
      if (found.state === 0) {
        found.state = 1;
      }
    } else if ((sortMode != null) && sortMode === 1) {
      found.state = 1;
    } else if ((sortMode != null) && sortMode === -1) {
      found.state = -1;
    } else {
      this.addSortRule(sourceName, 0);
    }
    this.updateRowData();
  };

  TableView.prototype.addLock = function(id) {
    this.lockList[id] = true;
    return true;
  };

  TableView.prototype.applySorting = function(rowData) {
    var finalList, j, k, len1, len2, rec, sorted;
    if (this.sortRules == null) {
      this.sortRules = [];
    }
    this.numLockedRows = Object.keys(this.lockList).length;
    if (this.sortRules.length === 0 && this.numLockedRows === 0) {
      return rowData;
    }
    sorted = rowData.sort((function(_this) {
      return function(a, b) {
        var aValue, bValue, j, len1, ref, rule;
        ref = _this.sortRules;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          rule = ref[j];
          if (rule.state === 0) {
            continue;
          }
          aValue = DataMap.getDataField(_this.primaryTableName, a.id, rule.source);
          bValue = DataMap.getDataField(_this.primaryTableName, b.id, rule.source);
          if ((aValue != null) && !bValue) {
            return rule.state;
          }
          if ((bValue != null) && !aValue) {
            return rule.state * -1;
          }
          if ((aValue == null) && (bValue == null)) {
            return 0;
          }
          if (rule.state === -1 && aValue < bValue) {
            return 1;
          }
          if (rule.state === -1 && aValue > bValue) {
            return -1;
          }
          if (rule.state === 1 && aValue < bValue) {
            return -1;
          }
          if (rule.state === 1 && aValue > bValue) {
            return 1;
          }
        }
        return 0;
      };
    })(this));
    if (this.numLockedRows > 0) {
      finalList = [];
      for (j = 0, len1 = sorted.length; j < len1; j++) {
        rec = sorted[j];
        if (this.lockList[rec.id] != null) {
          finalList.push(rec);
          rec.locked = true;
        }
      }
      for (k = 0, len2 = sorted.length; k < len2; k++) {
        rec = sorted[k];
        if (this.lockList[rec.id] == null) {
          finalList.push(rec);
        }
      }
      return finalList;
    }
    return sorted;
  };

  TableView.prototype.applyFilters = function() {
    var field, fieldList, fieldName, filterValue, filters, ref, strJavascript, tableName;
    strJavascript = "";
    if ((this.overallReduceFunction != null) && typeof this.overallReduceFunction === "string") {
      strJavascript += "try {\n" + this.overallReduceFunction + ";\n} catch (e) { console.log(\"eee=\",e); }\n";
    }
    filters = [];
    ref = this.currentFilters;
    for (tableName in ref) {
      fieldList = ref[tableName];
      for (fieldName in fieldList) {
        filterValue = fieldList[fieldName];
        field = "row['" + fieldName + "']";
        strJavascript += "if (typeof(" + field + ") == 'undefined') return false;\n";
        strJavascript += "if (" + field + " == null) return false;\n";
        strJavascript += "re = new RegExp('" + filterValue + "', 'i');\n";
        strJavascript += "if (!re.test(" + field + ")) return false;\n";
      }
    }
    strJavascript += "return true;\n";
    this.reduceFunction = new Function("row", strJavascript);
    return true;
  };

  TableView.prototype.updateFullHeight = function() {
    var h;
    if (this.fixedHeader) {
      return;
    }
    h = 0;
    if (this.showHeaders) {
      h = h + this.headerCellHeight;
    }
    if (this.showFilters) {
      h = h + this.filterCellHeight;
    }
    h = h + (this.totalAvailableRows * this.dataCellHeight);
    if (!this.fixedHeight) {
      this.elTableHolder.height(h);
    }
    return h;
  };

  TableView.prototype.updateColumnList = function() {
    var acol, c, col, columns, foundInActionCol, foundInGroup, j, k, l, len1, len2, len3, len4, len5, len6, n, o, p, ref, ref1, ref2, ref3, sortedColList, sortrule, source, total;
    this.colList = [];
    this.colByNum = {};
    if (this.showCheckboxes) {
      c = new TableViewColCheckbox(this.primaryTableName);
      this.colList.push(c);
    }
    columns = DataMap.getColumnsFromTable(this.primaryTableName, this.columnReduceFunction);
    columns = columns.sort(function(a, b) {
      return a.getOrder() - b.getOrder();
    });
    for (j = 0, len1 = columns.length; j < len1; j++) {
      col = columns[j];
      if (!col.getVisible()) {
        continue;
      }
      foundInActionCol = false;
      ref = this.actionColList;
      for (k = 0, len2 = ref.length; k < len2; k++) {
        acol = ref[k];
        if (acol.getSource() === col.getSource()) {
          foundInActionCol = true;
          break;
        }
      }
      if (foundInActionCol) {
        continue;
      }
      if (this.isColumnEmpty(col)) {
        continue;
      }
      this.colList.push(col);
    }
    total = 0;
    sortedColList = this.colList.sort(function(a, b) {
      return a.getOrder() - b.getOrder();
    });
    for (l = 0, len3 = sortedColList.length; l < len3; l++) {
      col = sortedColList[l];
      foundInGroup = false;
      ref1 = this.currentGroups;
      for (n = 0, len4 = ref1.length; n < len4; n++) {
        source = ref1[n];
        if (source === col.getSource()) {
          col.isGrouped = true;
          foundInGroup = true;
          break;
        }
      }
      if (foundInGroup) {
        continue;
      }
      this.colByNum[total] = col;
      total++;
    }
    ref2 = this.actionColList;
    for (o = 0, len5 = ref2.length; o < len5; o++) {
      acol = ref2[o];
      if (acol.constructor.name === "TableViewCol") {
        ref3 = this.sortRules;
        for (p = 0, len6 = ref3.length; p < len6; p++) {
          sortrule = ref3[p];
          if (sortrule.tableName === this.primaryTableName && sortrule.source === acol.getSource()) {
            acol.sort = sortrule.state;
          }
        }
        this.colByNum[total] = acol;
        total++;
      }
    }
    return true;
  };

  TableView.prototype.updateRowData = function() {
    var allData, col, currentGroupNumber, displayName, filteredData, groupedData, item, j, k, key, l, len1, len2, len3, len4, len5, len6, n, name, o, obj, p, ref, ref1, ref2, value;
    if (!this.isVisible()) {
      return;
    }
    this.applyFilters();
    this.rowDataRaw = [];
    allData = DataMap.getValuesFromTable(this.primaryTableName, this.reduceFunction);
    if (this.currentGroups.length === 0) {
      this.showGroupPadding = false;
      filteredData = this.applySorting(allData);
      for (j = 0, len1 = filteredData.length; j < len1; j++) {
        obj = filteredData[j];
        this.rowDataRaw.push({
          id: obj.id,
          group: null
        });
      }
      this.totalAvailableRows = this.rowDataRaw.length;
      this.updateColumnList();
      this.updateFullHeight();
      if (this.renderRequired) {
        this.real_render();
      }
      this.layoutShadow();
      this.updateScrollbarSettings();
      this.resetCachedFromSize();
      globalTableEvents.emitEvent("row_count", [this.primaryTableName, this.totalAvailableRows]);
      return;
    }
    groupedData = {};
    this.rowDataRaw = [];
    this.showGroupPadding = true;
    currentGroupNumber = 0;
    for (k = 0, len2 = allData.length; k < len2; k++) {
      item = allData[k];
      key = "";
      ref = this.currentGroups;
      for (l = 0, len3 = ref.length; l < len3; l++) {
        name = ref[l];
        if (key !== "") {
          key += ", ";
        }
        displayName = name;
        ref1 = this.colList;
        for (n = 0, len4 = ref1.length; n < len4; n++) {
          col = ref1[n];
          if (col.getSource() === name) {
            displayName = col.getName();
          }
        }
        value = DataMap.getDataField(this.primaryTableName, item.id, name);
        key += displayName + ": " + value;
      }
      if (groupedData[key] == null) {
        groupedData[key] = [];
      }
      groupedData[key].push(item);
    }
    ref2 = Object.keys(groupedData).sort();
    for (o = 0, len5 = ref2.length; o < len5; o++) {
      value = ref2[o];
      currentGroupNumber++;
      if (currentGroupNumber > 7) {
        currentGroupNumber = 1;
      }
      filteredData = groupedData[value];
      if (filteredData.length > 0) {
        this.rowDataRaw.push({
          id: null,
          type: "group",
          name: value,
          group: currentGroupNumber,
          count: filteredData.length
        });
        filteredData = this.applySorting(filteredData);
        for (p = 0, len6 = filteredData.length; p < len6; p++) {
          obj = filteredData[p];
          this.rowDataRaw.push({
            id: obj.id,
            group: currentGroupNumber,
            visible: true
          });
        }
      }
    }
    this.totalAvailableRows = this.rowDataRaw.length;
    this.updateColumnList();
    this.updateFullHeight();
    if (this.renderRequired) {
      this.real_render();
    }
    this.layoutShadow();
    this.updateScrollbarSettings();
    globalTableEvents.emitEvent("row_count", [this.primaryTableName, this.totalAvailableRows]);
    return true;
  };

  TableView.prototype.setStatusBarEnabled = function(isEnabled) {
    if (isEnabled == null) {
      isEnabled = true;
    }
    return this.showStatusBar = isEnabled;
  };

  TableView.prototype.isVisible = function() {
    var pos, tableWidth;
    if (this.elTableHolder == null) {
      return false;
    }
    pos = this.elTableHolder.position();
    if (pos == null) {
      return false;
    }
    tableWidth = this.elTableHolder.outerWidth();
    if (pos.top === 0 && pos.left === 0 && tableWidth === 0) {
      return false;
    }
    return true;
  };

  TableView.prototype.setHolderToBottom = function() {
    if (this.renderRequired) {
      this.real_render();
    }
    this.isFixedBottom = true;
    return this.updateFixedPosition();
  };

  TableView.prototype.updateFixedPosition = function(attemptCounter) {
    var height, newHeight, newWidth, offset, pos, tableHeight, tableWidth;
    if (attemptCounter == null) {
      attemptCounter = 0;
    }
    if ((this.isFixedBottom == null) || this.isFixedBottom !== true) {
      return;
    }
    height = $(window).height();
    pos = this.elTableHolder.position();
    offset = this.elTableHolder.offset();
    tableWidth = this.elTableHolder.outerWidth();
    tableHeight = this.elTableHolder.outerHeight();
    if ((pos == null) || (offset == null) || pos.top === 0 && pos.left === 0 && tableWidth === 0) {
      if ((attemptCounter != null) && attemptCounter === 3) {
        return;
      }
      setTimeout((function(_this) {
        return function() {
          if (attemptCounter == null) {
            attemptCounter = 0;
          }
          return _this.updateFixedPosition(attemptCounter + 1);
        };
      })(this), 10);
      return;
    }
    newHeight = height - pos.top;
    newHeight = Math.floor(newHeight);
    if (newHeight < minHeightOfTable) {
      newHeight = minHeightOfTable;
    }
    this.elTableHolder.height(newHeight);
    newWidth = this.elTableHolder.outerWidth();
    this.resetCachedFromSize();
    this.lastNewHeight = newHeight;
    this.lastNewWidth = newWidth;
    return true;
  };

  TableView.prototype.allowCustomize = function(customizableColumns) {
    this.customizableColumns = customizableColumns != null ? customizableColumns : true;
  };

  TableView.prototype.getTotalActionWidth = function() {
    var col, j, len1, ref, total;
    total = 0;
    ref = this.actionColList;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      col = ref[j];
      total += col.getWidth();
    }
    return total;
  };

  TableView.prototype.getTableTotalRows = function() {
    return this.totalAvailableRows;
  };

  TableView.prototype.getTableTotalCols = function() {
    var col, j, len1, ref, total;
    total = 0;
    ref = this.colList;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      col = ref[j];
      if ((col.isGrouped != null) && col.isGrouped === true) {
        continue;
      }
      total++;
    }
    return total;
  };

  TableView.prototype.getTableVisibleWidth = function() {
    var maxWidth;
    if ((this.cachedVisibleWidth != null) && this.cachedVisibleWidth > 0) {
      return this.cachedVisibleWidth;
    }
    maxWidth = this.elTableHolder.width();
    if ((this.virtualScrollV != null) && this.virtualScrollV.visible) {
      maxWidth -= 20;
    }
    return this.cachedVisibleWidth = maxWidth - this.getTotalActionWidth();
  };

  TableView.prototype.getTableVisibleHeight = function() {
    var maxHeight;
    if ((this.cachedVisibleHeight != null) && this.cachedVisibleHeight > 0) {
      return this.cachedVisibleHeight;
    }
    maxHeight = this.elTableHolder.height();
    if ((this.virtualScrollH != null) && this.virtualScrollH.visible) {
      maxHeight -= 20;
    }
    return this.cachedVisibleHeight = maxHeight;
  };

  TableView.prototype.getTableMaxVisibleRows = function() {
    var maxHeight, rowNum, visRowCount, y;
    if (this.cachedMaxTotalVisibleRows != null) {
      return this.cachedMaxTotalVisibleRows;
    }
    y = 0;
    visRowCount = 0;
    maxHeight = this.getTableVisibleHeight();
    rowNum = this.getTableTotalRows() - 1;
    while (y < maxHeight) {
      if (rowNum < 0) {
        break;
      }
      y = y + this.getRowHeight({
        rowNum: rowNum,
        visibleRow: visRowCount
      });
      rowNum--;
      visRowCount++;
    }
    if (visRowCount > 0) {
      this.cachedMaxTotalVisibleRows = visRowCount;
    }
    return visRowCount;
  };

  TableView.prototype.getTableVisibleRows = function() {
    var maxHeight, rowNum, totalRows, visRowCount, y;
    if (this.cachedTotalVisibleRows != null) {
      return this.cachedTotalVisibleRows;
    }
    y = 0;
    visRowCount = 0;
    rowNum = this.offsetShowingTop;
    maxHeight = this.getTableVisibleHeight();
    totalRows = this.getTableTotalRows();
    while (y < maxHeight) {
      if (rowNum >= totalRows) {
        break;
      }
      y = y + this.getRowHeight({
        rowNum: rowNum,
        visibleRow: visRowCount
      });
      visRowCount++;
      rowNum++;
    }
    if (visRowCount > 0) {
      this.cachedTotalVisibleRows = visRowCount;
    }
    return visRowCount;
  };

  TableView.prototype.getTableMaxVisibleCols = function() {
    var col, colNum, location, maxWidth, visColCount, x;
    if (this.cachedMaxTotalVisibleCol != null) {
      return this.cachedMaxTotalVisibleCol;
    }
    visColCount = 0;
    x = 0;
    colNum = this.getTableTotalCols() - 1;
    maxWidth = this.getTableVisibleWidth();
    while (x < maxWidth && colNum >= 0) {
      col = this.colByNum[colNum];
      location = {
        colNum: colNum,
        tableName: col.tableName,
        sourceName: col.getSource(),
        visibleCol: colNum
      };
      if ((colNum > 0) && this.shouldSkipCol(location)) {
        colNum--;
        continue;
      }
      col.currentWidth = this.getColWidth(location);
      x = x + col.currentWidth;
      visColCount++;
      colNum--;
    }
    if (visColCount > 0) {
      this.cachedMaxTotalVisibleCol = visColCount;
    }
    return visColCount;
  };

  TableView.prototype.getTableVisibleCols = function() {
    var col, colNum, location, maxWidth, totalCols, visColCount, x;
    if (this.cachedTotalVisibleCols != null) {
      return this.cachedTotalVisibleCols;
    }
    visColCount = 0;
    x = 0;
    colNum = this.offsetShowingLeft;
    maxWidth = this.getTableVisibleWidth();
    totalCols = this.getTableTotalCols();
    while (x < maxWidth && colNum < totalCols) {
      col = this.colByNum[colNum];
      location = {
        colNum: colNum,
        tableName: col.tableName,
        sourceName: col.getSource(),
        visibleCol: colNum
      };
      if ((colNum < totalCols) && this.shouldSkipCol(location)) {
        console.log("shouldSkip ", location.colNum);
        colNum++;
        continue;
      }
      if (colNum >= totalCols) {
        break;
      }
      col.currentWidth = this.getColWidth(location);
      x = x + col.currentWidth;
      visColCount++;
      colNum++;
    }
    if (visColCount > 0) {
      this.cachedTotalVisibleCols = visColCount;
    }
    return visColCount;
  };

  TableView.prototype.getColWidth = function(location) {
    var maxWidth;
    if (location.cellType === "group") {
      maxWidth = this.getTableVisibleWidth();
      if (location.visibleCol === 1) {
        return 200;
      }
      if (location.visibleCol === 2) {
        return 90;
      }
      if (location.visibleCol === 3) {
        return maxWidth - 290;
      }
      return 0;
    }
    if (this.colByNum[location.colNum] == null) {
      return 10;
    }
    if ((this.colByNum[location.colNum].actualWidth != null) && !isNaN(this.colByNum[location.colNum].actualWidth)) {
      return Math.floor(this.colByNum[location.colNum].actualWidth);
    }
    return this.colByNum[location.colNum].getWidth();
  };

  TableView.prototype.getRowHeight = function(location) {
    return this.dataCellHeight;
  };

  TableView.prototype.getCellEditable = function(location) {
    if (this.colByNum[location.colNum] == null) {
      return false;
    }
    return this.colByNum[location.colNum].getEditable();
  };

  TableView.prototype.getCellClickable = function(location) {
    if (this.colByNum[location.colNum] != null) {
      return this.colByNum[location.colNum].getClickable();
    }
    return false;
  };

  TableView.prototype.getCellStriped = function(location) {
    if ((this.showHeaders || this.showFilters) && location.visibleRow === 0) {
      return false;
    }
    if ((this.showHeaders && this.showFilters) && location.visibleRow === 1) {
      return false;
    }
    if (location.cellType === "group") {
      return false;
    }
    return location.visibleRow % 2 === 0;
  };

  TableView.prototype.getCellGroupNumber = function(location) {
    if (location.cellType === "group") {
      return this.rowDataRaw[location.rowNum].group;
    }
    if (location.cellType === "invalid" || location.visibleCol > 0) {
      return null;
    }
    if (this.rowDataRaw[location.rowNum] == null) {
      return null;
    }
    return this.rowDataRaw[location.rowNum].group;
  };

  TableView.prototype.getCellAlign = function(location) {
    if (location.cellType === "group") {
      if (location.visibleCol === 1) {
        return "left";
      }
      return "right";
    }
    return this.colByNum[location.colNum].getAlign();
  };

  TableView.prototype.getCellTablename = function(location) {
    if (location.cellType !== "data") {
      return this.primaryTableName;
    }
    return this.colByNum[location.colNum].tableName;
  };

  TableView.prototype.getCellCalculation = function(location) {
    if (location.cellType === "invalid") {
      return null;
    }
    if (this.colByNum[location.colNum] == null) {
      return null;
    }
    return this.colByNum[location.colNum].getIsCalculation();
  };

  TableView.prototype.getCellSource = function(location) {
    if (location.cellType === "invalid") {
      return null;
    }
    if (this.colByNum[location.colNum] == null) {
      return null;
    }
    return this.colByNum[location.colNum].getSource();
  };

  TableView.prototype.getCellRecordID = function(location) {
    if (this.rowDataRaw[location.rowNum] == null) {
      return 0;
    }
    return this.rowDataRaw[location.rowNum].id;
  };

  TableView.prototype.getCellFormatterName = function(location) {
    return this.colByNum[location.colNum].getFormatterName();
  };

  TableView.prototype.shouldAdvanceCol = function(location) {
    return true;
  };

  TableView.prototype.getCellDataPath = function(location) {
    if (location.cellType === "data") {
      return "/" + location.tableName + "/" + location.recordId + "/" + location.sourceName;
    }
    if (location.cellType === "group") {
      return "/group/" + location.rowNum;
    }
    return "/unknown/" + location.celltype;
  };

  TableView.prototype.setHeaderFilterField = function(location) {
    if (location.cell.children.length === 0) {
      location.cell.addClass("dataFilterWrapper");
      location.cell.add("input", "dataFilter");
      location.cell.children[0].bind("keyup", this.onFilterKeypress);
    }
    location.cell.children[0].setDataPath("/" + location.tableName + "/Filter/" + location.sourceName);
    return true;
  };

  TableView.prototype.setHeaderField = function(location) {
    var j, len1, ref, sort;
    location.cell.currentCol = location.colNum;
    location.cell.html("");
    location.cell.removeClass("spacer");
    if (location.visibleRow === 0) {
      this.colByNum[location.colNum].sort = 0;
      ref = this.sortRules;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        sort = ref[j];
        if (sort.source === this.colByNum[location.colNum].getSource()) {
          this.colByNum[location.colNum].sort = sort.state;
        }
      }
      this.colByNum[location.colNum].RenderHeader(location.cell, location);
      location.cell.setDataPath("/" + location.tableName + "/Header/" + location.sourceName);
    } else {
      this.setHeaderFilterField(location);
    }
    return true;
  };

  TableView.prototype.setHeaderGroupField = function(location) {
    if (location.visibleRow === 0) {
      location.cell.addClass("tableHeaderField");
    } else if (location.visibleRow === 1) {
      location.cell.addClass("dataFilterWrapper");
    }
    return true;
  };

  TableView.prototype.setDataField = function(location) {
    var aValue, bValue, col, displayValue;
    if (location.cellType === "invalid") {
      location.cell.hide();
      return;
    }
    if (location.cellType === "group") {
      if (location.visibleCol === 1) {
        location.cell.html(this.rowDataRaw[location.rowNum].name);
      } else if (location.visibleCol === 3) {
        location.cell.html("");
      } else if (location.visibleCol === 2) {
        if (this.rowDataRaw[location.rowNum].count === 1) {
          location.cell.html(this.rowDataRaw[location.rowNum].count + " Record");
        } else {
          location.cell.html(this.rowDataRaw[location.rowNum].count + " Records");
        }
      }
      return;
    }
    col = this.colByNum[location.colNum];
    if (col.getSource() === "row_selected") {
      if (this.getRowLocked(this.rowDataRaw[location.rowNum].id)) {
        location.cell.html("<i class='fa fa-lock'></i>");
      } else if (this.getRowSelected(this.rowDataRaw[location.rowNum].id)) {
        location.cell.html(this.imgChecked);
      } else {
        location.cell.html(this.imgNotChecked);
      }
    } else {
      displayValue = DataMap.getDataFieldFormatted(col.tableName, location.recordId, location.sourceName);
      location.cell.html(displayValue);
    }
    if ((this.lockList != null) && this.lockList.length > 0) {
      aValue = DataMap.getDataField(col.tableName, location.recordId, location.sourceName);
      if (typeof aValue === "number") {
        bValue = DataMap.getDataField(col.tableName, this.lockList[0], location.sourceName);
        if (aValue > bValue) {
          location.cell.addClass("valueHigher");
          location.cell.removeClass("valueLower");
        } else if (aValue < bValue) {
          location.cell.addClass("valueLower");
          location.cell.removeClass("valueHigher");
        } else {
          location.cell.removeClass("valueLower");
          location.cell.removeClass("valueHigher");
        }
      } else {
        location.cell.removeClass("valueLower");
        location.cell.removeClass("valueHigher");
      }
    }
    return true;
  };

  TableView.prototype.shouldSkipCol = function(location) {
    if (this.colByNum[location.colNum] == null) {
      return true;
    }
    return false;
  };

  TableView.prototype.getRowType = function(location) {
    if (this.isHeaderCell(location)) {
      return "locked";
    }
    if (this.rowDataRaw[location.rowNum] == null) {
      return "invalid";
    }
    if ((this.rowDataRaw[location.rowNum] != null) && (this.rowDataRaw[location.rowNum].type != null)) {
      return "group";
    }
    return "data";
  };

  TableView.prototype.getCellType = function(location) {
    if (this.isHeaderCell(location)) {
      return "locked";
    }
    if ((location.rowNum == null) || (this.rowDataRaw[location.rowNum] == null)) {
      return "invalid";
    }
    if (this.rowDataRaw[location.rowNum] == null) {
      return "invalid";
    }
    if (this.rowDataRaw[location.rowNum].type != null) {
      return this.rowDataRaw[location.rowNum].type;
    }
    return "data";
  };

  TableView.prototype.isHeaderCell = function(location) {
    if (location.visibleRow === 1 && (this.showHeaders && this.showFilters)) {
      return true;
    }
    if (location.visibleRow === 0 && (this.showHeaders || this.showFilters)) {
      return true;
    }
    return false;
  };

  TableView.prototype.isResizable = function(location) {
    if (!this.showResize) {
      return false;
    }
    if (location.visibleRow > 0) {
      return false;
    }
    if (!location.isHeader) {
      return false;
    }
    if (this.showGroupPadding && location.visibleCol === 0) {
      return false;
    }
    if (location.sourceName === "row_selected") {
      return false;
    }
    if (location.colNum >= location.totalColCount) {
      return false;
    }
    return true;
  };

  TableView.prototype.initializeSpacerCell = function(location, spacer) {
    if (location.groupNum != null) {
      spacer.setClassOne("groupRowChart" + location.groupNum, /^groupRowChart/);
    } else {
      spacer.setClassOne(null, /^groupRowChart/);
    }
    spacer.setDataPath("grab");
    spacer.setDataValue("rn", location.rowNum);
    spacer.setDataValue("cn", location.colNum);
    spacer.setDataValue("vr", 0);
    spacer.setDataValue("vc", 0);
    return true;
  };

  TableView.prototype.updateCellClasses = function(location, div) {
    div.show();
    div.setDataValue("rn", location.rowNum);
    div.setDataValue("cn", location.colNum);
    div.setDataValue("vr", location.visibleRow);
    div.setDataValue("vc", location.visibleCol);
    if (location.groupNum != null) {
      div.setClassOne("groupRowChart" + location.groupNum, /^groupRowChart/);
    } else {
      div.setClassOne(null, /^groupRowChart/);
    }
    location.cell.setClass("even", this.getCellStriped(location));
    location.cell.setClass("first-action", false);
    location.align = this.getCellAlign(location);
    location.cell.setClass("text-right", location.align === "right");
    location.cell.setClass("text-center", location.align === "center");
    location.cell.setClass("calculation", this.getCellCalculation(location));
    return true;
  };

  TableView.prototype.incrementColumn = function(location, showSpacer) {
    if (location.x + location.colWidth > location.maxWidth) {
      location.colWidth = location.maxWidth - location.x;
    }
    if (location.spacer != null) {
      location.cell.move(location.x, 0, location.colWidth - 3, location.rowHeight);
      location.spacer.move(location.colWidth + location.x - 3, 0, 3, location.rowHeight);
      location.spacer.show();
      location.spacer.addClass("spacer");
      location.spacer.html("");
      location.shadowVisibleCol++;
    } else {
      location.cell.move(location.x, 0, location.colWidth, location.rowHeight);
    }
    location.x += location.colWidth;
    location.shadowVisibleCol++;
    location.visibleCol++;
    return true;
  };

  TableView.prototype.updateVisibleActionRowText = function(location, acol, cell) {
    var currentValue, displayValue, e;
    location.tableName = acol.tableName;
    location.sourceName = acol.getSource();
    cell.setClass("clickable", acol.getClickable());
    if (acol.render != null) {
      try {
        currentValue = DataMap.getDataField(location.tableName, location.recordId, location.sourceName);
        displayValue = acol.render(currentValue, location.tableName, location.sourceName, location.recordId);
      } catch (error) {
        e = error;
        console.log("updateVisibleActionRow locaiton=", location);
        console.log("Custom render error:", e);
        displayValue = "";
      }
      cell.html(displayValue);
    } else {
      displayValue = DataMap.getDataFieldFormatted(acol.tableName, location.recordId, acol.getSource());
      cell.html(displayValue);
    }
    return true;
  };

  TableView.prototype.updateVisibleActionRow = function(location) {
    var acol, cell, count, j, len1, ref, results;
    count = 0;
    ref = this.actionColList;
    results = [];
    for (j = 0, len1 = ref.length; j < len1; j++) {
      acol = ref[j];
      if (this.shadowCells[location.visibleRow].children.length <= location.shadowVisibleCol) {
        this.shadowCells[location.visibleRow].addDiv("cell");
        this.shadowCells[location.visibleRow].children[location.shadowVisibleCol].setAbsolute();
      }
      cell = this.shadowCells[location.visibleRow].children[location.shadowVisibleCol];
      cell.show();
      cell.move(location.x, 0, acol.getWidth(), location.rowHeight);
      cell.setClass("text-right", acol.getAlign() === "right");
      cell.setClass("text-center", acol.getAlign() === "center");
      cell.setClass("first-action", count++ === 0);
      cell.removeClass("spacer");
      cell.setClass("even", this.getCellStriped(location));
      cell.setDataValue("rn", location.rowNum);
      cell.setDataValue("cn", location.colNum);
      cell.setDataValue("vr", location.visibleRow);
      cell.setDataValue("vc", location.visibleCol);
      cell.setDataValue("action", acol.getSource());
      if (location.isHeader) {
        cell.setDataPath("/" + this.primaryTableName + "/Header/" + (acol.getSource()));
      } else {
        cell.setDataPath("/" + this.primaryTableName + "/" + location.recordId + "/" + (acol.getSource()));
      }
      if (location.groupNum != null) {
        cell.setClassOne("groupRowChart" + location.groupNum, /^groupRowChart/);
      } else {
        cell.setClassOne(null, /^groupRowChart/);
      }
      if (location.isHeader) {
        if (location.visibleRow === 0) {
          acol.RenderHeader(cell, location);
          cell.show();
        } else {
          location.cell = cell;
          location.sourceName = acol.getSource();
          this.setHeaderFilterField(location);
        }
      } else {
        if (location.state === "group") {
          cell.removeClass("clickable");
          cell.html("");
        } else {
          this.updateVisibleActionRowText(location, acol, cell);
        }
      }
      location.x += acol.getWidth();
      results.push(location.shadowVisibleCol++);
    }
    return results;
  };

  TableView.prototype.updateVisibleTextRow = function(location) {
    location.x = 0;
    location.visibleCol = 0;
    location.colNum = this.offsetShowingLeft;
    location.shadowVisibleCol = 0;
    while (location.x < location.maxWidth) {
      if (location.colNum >= location.totalColCount) {
        break;
      }
      if (this.shadowCells[location.visibleRow].children.length <= location.shadowVisibleCol) {
        this.shadowCells[location.visibleRow].addDiv("cell");
        this.shadowCells[location.visibleRow].children[location.shadowVisibleCol].setAbsolute();
      }
      location.cell = this.shadowCells[location.visibleRow].children[location.shadowVisibleCol];
      location.spacer = null;
      location.isHeader = this.isHeaderCell(location);
      location.groupNum = this.getCellGroupNumber(location);
      location.cellType = this.getCellType(location);
      location.tableName = this.getCellTablename(location);
      location.sourceName = this.getCellSource(location);
      location.colWidth = this.getColWidth(location);
      if (location.cellType === "invalid") {
        console.log("Invalid cell at colNum=" + location.colNum);
        break;
      }
      if (this.shouldSkipCol(location)) {
        location.colNum++;
        continue;
      }
      if (this.isResizable(location)) {
        if (this.shadowCells[location.visibleRow].children.length <= location.shadowVisibleCol + 1) {
          this.shadowCells[location.visibleRow].addDiv("spacer");
          this.shadowCells[location.visibleRow].children[location.shadowVisibleCol + 1].setAbsolute();
        }
        this.initializeSpacerCell(location, this.shadowCells[location.visibleRow].children[location.shadowVisibleCol + 1]);
        location.spacer = this.shadowCells[location.visibleRow].children[location.shadowVisibleCol + 1];
      }
      if (this.showGroupPadding && location.visibleCol === 0) {
        location.colWidth = this.groupPaddingWidth;
        if (!location.isHeader) {
          location.cell.setClassOne("groupRowChart" + location.groupNum, /^groupRowChart/);
          location.cell.removeClass("even");
          location.cell.html("");
        } else {
          this.setHeaderGroupField(location);
        }
        this.incrementColumn(location);
        continue;
      }
      this.updateCellClasses(location, location.cell);
      if (location.isHeader) {
        this.setHeaderField(location);
      } else {
        location.recordId = this.getCellRecordID(location);
        location.cell.setClass("clickable", this.getCellClickable(location));
        location.cell.setClass("editable", this.getCellEditable(location));
        location.cell.setClass("row_checked", this.getRowSelected(location.recordId));
        location.cell.setClass("row_locked", this.getRowLocked(location.recordId));
        location.cell.setDataPath(this.getCellDataPath(location));
        this.setDataField(location);
      }
      this.incrementColumn(location);
      if (this.shouldAdvanceCol(location)) {
        location.colNum++;
      }
    }
    this.updateVisibleActionRow(location);
    while (this.shadowCells[location.visibleRow].children[location.shadowVisibleCol] != null) {
      this.shadowCells[location.visibleRow].children[location.shadowVisibleCol].resetDataValues();
      this.shadowCells[location.visibleRow].children[location.shadowVisibleCol].hide();
      this.shadowCells[location.visibleRow].children[location.shadowVisibleCol].setDataPath(null);
      location.shadowVisibleCol++;
    }
    return true;
  };

  TableView.prototype.updateVisibleText = function() {
    var groupState, hasFinishedLockedRows, location, lockRowsRemain, marginRight, marginTop, maxHeight, r1, r2, refreshRequired, totalRowCount, y;
    if (this.elTheTable == null) {
      return;
    }
    if ((this.offsetShowingTop == null) || this.offsetShowingTop < 0) {
      this.offsetShowingTop = 0;
    }
    if ((this.offsetShowingLeft == null) || this.offsetShowingLeft < 0) {
      this.offsetShowingLeft = 0;
    }
    if (this.rowDataRaw.length === 0) {
      if (this.noDataCell == null) {
        this.noDataCell = this.elTheTable.addDiv("tableRow");
        this.noDataCell.setAbsolute();
        this.noDataCell.setZ(1);
      } else if (this.noDataCell.visible) {
        return;
      }
      marginRight = this.virtualScrollV.visible ? this.virtualScrollV.displaySize : 0;
      marginTop = this.headerCellHeight + this.getRowHeight();
      this.noDataCell.move(0, this.headerCellHeight + this.getRowHeight(), this.elTableHolder.width() - marginRight, this.elTableHolder.height() - marginTop);
      this.noDataCell.html("No data available.");
      this.noDataCell.show();
      r1 = this.virtualScrollV.setRange(0, 0, 0, 0);
      r2 = this.virtualScrollH.setRange(0, 0, 0, 0);
      return;
    }
    if (this.noDataCell != null) {
      this.noDataCell.hide();
    }
    y = 0;
    groupState = null;
    maxHeight = this.getTableVisibleHeight();
    totalRowCount = this.getTableTotalRows();
    refreshRequired = false;
    if (this.offsetShowingTop >= totalRowCount) {
      this.offsetShowingTop = totalRowCount - 1;
    }
    location = {
      visibleRow: 0,
      rowNum: 0,
      totalColCount: this.getTableTotalCols(),
      maxWidth: this.getTableVisibleWidth(),
      actionWidth: this.getTotalActionWidth()
    };
    lockRowsRemain = this.numLockedRows;
    hasFinishedLockedRows = false;
    while (y < maxHeight) {
      if (lockRowsRemain === 0 && !hasFinishedLockedRows) {
        hasFinishedLockedRows = true;
        location.rowNum += this.offsetShowingTop;
      }
      location.rowHeight = this.getRowHeight(location);
      location.state = this.getRowType(location);
      if (this.shadowCells[location.visibleRow] == null) {
        this.shadowCells[location.visibleRow] = this.elTheTable.addDiv("tableRow");
        this.shadowCells[location.visibleRow].setAbsolute();
        this.shadowCells[location.visibleRow].show();
      }
      this.shadowCells[location.visibleRow].move(0, y, location.maxWidth + location.actionWidth, location.rowHeight);
      if (location.state === "invalid") {
        if (this.offsetShowingTop > 0) {
          this.offsetShowingTop--;
          refreshRequired = true;
        }
        break;
      } else if (location.state === "skip") {
        location.rowNum++;
        continue;
      } else if (location.state === "group") {
        this.shadowCells[location.visibleRow].show();
        this.shadowCells[location.visibleRow].removeClass("tableRow");
        this.updateVisibleTextRow(location);
        location.rowNum++;
      } else if (location.state === "locked") {
        this.shadowCells[location.visibleRow].show();
        this.shadowCells[location.visibleRow].removeClass("tableRow");
        this.updateVisibleTextRow(location);
      } else if (location.state === "data") {
        this.shadowCells[location.visibleRow].show();
        this.shadowCells[location.visibleRow].addClass("tableRow");
        this.updateVisibleTextRow(location);
        location.rowNum++;
        if (lockRowsRemain > 0) {
          lockRowsRemain--;
        }
      } else {
        location.rowNum++;
      }
      y += location.rowHeight;
      location.visibleRow++;
    }
    if (refreshRequired) {
      return true;
    }
    while (this.shadowCells[location.visibleRow] != null) {
      this.shadowCells[location.visibleRow].hide();
      this.shadowCells[location.visibleRow].resetDataValues();
      location.visibleRow++;
    }
    return true;
  };

  TableView.prototype.resetCachedFromScroll = function() {
    this.cachedTotalVisibleCols = null;
    this.cachedTotalVisibleRows = null;
    this.cachedMaxTotalVisibleCol = null;
    this.cachedMaxTotalVisibleRows = null;
    this.onMouseOut();
    return true;
  };

  TableView.prototype.resetCachedFromSize = function() {
    var col, j, len1, ref;
    this.cachedTotalVisibleCols = null;
    this.cachedTotalVisibleRows = null;
    this.cachedVisibleWidth = null;
    this.cachedVisibleHeight = null;
    this.cachedLayoutShadowWidth = null;
    ref = this.colList;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      col = ref[j];
      col.currentCol = null;
    }
    this.layoutShadow();
    this.onMouseOut();
    return true;
  };

  TableView.prototype.updateScrollbarSettings = function() {
    var currentVisibleCols, currentVisibleRows, maxAvailableCols, maxAvailableRows, r1, r2;
    currentVisibleCols = this.getTableMaxVisibleCols();
    currentVisibleRows = this.getTableMaxVisibleRows();
    maxAvailableRows = this.getTableTotalRows();
    maxAvailableCols = this.getTableTotalCols();
    if (this.offsetShowingTop >= maxAvailableRows - currentVisibleRows) {
      this.offsetShowingTop = maxAvailableRows - currentVisibleRows;
    }
    if (this.offsetShowingLeft >= maxAvailableCols - currentVisibleCols) {
      this.offsetShowingLeft = maxAvailableCols - currentVisibleCols;
    }
    if (this.offsetShowingTop < 0) {
      this.offsetShowingTop = 0;
    }
    if (this.offsetShowingLeft < 0) {
      this.offsetShowingLeft = 0;
    }
    if (this.elStatusScrollTextRows != null) {
      this.elStatusScrollTextRows.html("Rows " + (this.offsetShowingTop + 1) + " - " + (this.offsetShowingTop + currentVisibleRows) + " of " + maxAvailableRows);
      this.elStatusScrollTextCols.html("Cols " + (this.offsetShowingLeft + 1) + "-" + (this.offsetShowingLeft + currentVisibleCols) + " of " + maxAvailableCols);
    }
    r1 = this.virtualScrollV.setRange(0, maxAvailableRows, currentVisibleRows, this.offsetShowingTop);
    r2 = this.virtualScrollH.setRange(0, maxAvailableCols, currentVisibleCols, this.offsetShowingLeft);
    if (r1 || r2) {
      this.resetCachedFromSize();
    }
    return this.updateVisibleText();
  };

  TableView.prototype.isColumnEmpty = function(col) {
    var j, len1, obj, ref, source, value;
    if (this.rowDataRaw.length === 0) {
      return false;
    }
    if (col.getEditable() === true) {
      return false;
    }
    if (col.getIsCalculation() === true) {
      return false;
    }
    if (this.cachedColumnEmpty == null) {
      this.cachedColumnEmpty = {};
    }
    if (this.cachedColumnEmpty[col.getSource()] != null) {
      return this.cachedColumnEmpty[col.getSource()];
    }
    this.cachedColumnEmpty[col.getSource()] = false;
    source = col.getSource();
    ref = this.rowDataRaw;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      obj = ref[j];
      if (obj.id == null) {
        continue;
      }
      value = DataMap.getDataField(col.tableName, obj.id, source);
      if (value == null) {
        continue;
      }
      if (typeof value === "string" && value.length > 0) {
        return false;
      }
      if (typeof value === "number" && value !== 0) {
        return false;
      }
      if (typeof value === "boolean") {
        return false;
      }
      if (typeof value === "object") {
        return false;
      }
    }
    this.cachedColumnEmpty[col.getSource()] = true;
    return true;
  };

  TableView.prototype.findBestFit = function(col) {
    var j, len, len1, max, obj, ref, source, value;
    if (this.cachedBestFit == null) {
      this.cachedBestFit = {};
    }
    if (this.cachedBestFit[col.getSource()]) {
      return this.cachedBestFit[col.getSource()];
    }
    max = 10;
    source = col.getSource();
    ref = this.rowDataRaw;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      obj = ref[j];
      if (obj.id == null) {
        continue;
      }
      value = DataMap.getDataFieldFormatted(col.tableName, obj.id, source);
      if (value == null) {
        continue;
      }
      len = value.toString().length;
      if (len > max) {
        max = len;
      }
    }
    if (max < 10) {
      max = 10;
    }
    if (max > 40) {
      max = 40;
    }
    this.cachedBestFit[col.getSource()] = max * 8;
    return max * 8;
  };

  TableView.prototype.setAutoFillWidth = function() {
    this.autoFitWidth = true;
    delete this.cachedLayoutShadowWidth;
    return true;
  };

  TableView.prototype.layoutShadow = function() {
    var autoAdjustableColumns, col, colNum, diffAmount, i, j, k, l, len1, len2, len3, location, maxWidth, ref, ref1, totalWidth, w;
    maxWidth = this.getTableVisibleWidth();
    if ((this.cachedLayoutShadowWidth != null) && this.cachedLayoutShadowWidth === maxWidth) {
      return;
    }
    this.cachedLayoutShadowWidth = maxWidth;
    autoAdjustableColumns = [];
    ref = this.colList;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      i = ref[j];
      if (i.getAutoSize()) {
        if (i.actualWidth == null) {
          i.actualWidth = this.findBestFit(i);
        }
        autoAdjustableColumns.push(i);
      }
    }
    if ((this.autoFitWidth == null) || this.autoFitWidth === false) {
      return false;
    }
    totalWidth = 0;
    colNum = 0;
    ref1 = this.colList;
    for (k = 0, len2 = ref1.length; k < len2; k++) {
      i = ref1[k];
      if (i.isGrouped) {
        continue;
      }
      location = {
        colNum: colNum,
        visibleCol: colNum,
        tableName: this.primaryTableName,
        sourceName: i.getSource()
      };
      w = this.getColWidth(location);
      totalWidth += w;
      colNum++;
    }
    diffAmount = (maxWidth - totalWidth) / autoAdjustableColumns.length;
    diffAmount = Math.floor(diffAmount);
    for (l = 0, len3 = autoAdjustableColumns.length; l < len3; l++) {
      col = autoAdjustableColumns[l];
      col.actualWidth += diffAmount;
    }
    return true;
  };

  TableView.prototype.updateStatusText = function() {
    var message, str;
    message = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if (this.elStatusText == null) {
      return;
    }
    str = message.join(", ");
    this.elStatusText.html(str);
    return true;
  };

  TableView.prototype.render = function() {
    if (this.widgetBase == null) {
      this.renderRequired = true;
    }
    return true;
  };

  TableView.prototype.real_render = function() {
    var outerContainer, tableWrapper;
    this.renderRequired = false;
    if (this.shadowCells == null) {
      this.shadowCells = {};
    }
    if (!this.fixedHeader) {
      this.elTableHolder.width("100%");
    }
    this.elTableHolder.html("");
    this.widgetBase = new WidgetBase();
    tableWrapper = this.widgetBase.addDiv("table-wrapper", "tableWrapper" + this.gid);
    outerContainer = tableWrapper.addDiv("outer-container");
    this.elTheTable = outerContainer.addDiv("inner-container tableview");
    this.virtualScrollV = new VirtualScrollArea(outerContainer, true);
    this.virtualScrollH = new VirtualScrollArea(outerContainer, false);
    if ((this.showStatusBar != null) && this.showStatusBar === true) {
      this.virtualScrollH.bottomPadding = 26;
      this.virtualScrollH.resize();
      this.virtualScrollV.bottomPadding = 26;
      this.virtualScrollV.resize();
      this.elStatusBar = tableWrapper.addDiv("statusbar");
      this.elStatusText = this.elStatusBar.addDiv("scrollStatusText");
      this.elStatusText.html("Ready.");
      this.elStatusScrollTextRows = this.elStatusBar.addDiv("scrollTextRows");
      this.elStatusScrollTextRows.html("");
      this.elStatusScrollTextCols = this.elStatusBar.addDiv("scrollTextCols");
      this.elStatusScrollTextCols.html("");
      this.elStatusActionCopy = this.elStatusBar.addDiv("statusActionsCopy");
      this.elStatusActionCopy.html("<i class='fa fa-copy'></i> Copy");
      this.elStatusActionCopy.on("click", this.onActionCopyCell);
    }
    if ((this.rowDataRaw == null) || this.rowDataRaw.length === 0) {
      this.updateRowData();
    }
    this.layoutShadow();
    this.updateVisibleText();
    this.elTableHolder.append(tableWrapper.el);
    this.internalSetupMouseEvents();
    this.contextMenuCallSetup = 0;
    this.setupContextMenu(this.contextMenuCallbackFunction);
    this.tooltipWindow = new FloatingWindow(0, 0, 100, 100, this.elTableHolder);
    return true;
  };

  TableView.prototype.sortByColumn = function(name, type) {
    var col, key, ref, sortType;
    if (type === "ASC") {
      sortType = 1;
    } else if (type === "DSC") {
      sortType = -1;
    } else {
      sortType = 0;
    }
    ref = this.colByNum;
    for (key in ref) {
      col = ref[key];
      if (col.getSource() === name) {
        this.addSortRule(name, sortType);
        return true;
      }
    }
    return false;
  };

  TableView.prototype.groupBy = function(columnSource) {
    var j, len1, name, ref;
    ref = this.currentGroups;
    for (j = 0, len1 = ref.length; j < len1; j++) {
      name = ref[j];
      if (name === columnSource) {
        return;
      }
    }
    this.currentGroups.push(columnSource);
    this.updateRowData();
    this.updateVisibleText();
  };

  TableView.prototype.onFilterKeypress = function(e) {
    var columnName, keyValue, parts, tableName;
    parts = e.path.split('/');
    tableName = parts[1];
    keyValue = parts[2];
    columnName = parts[3];
    if (this.getColumnType(columnName) !== 1) {
      console.log("Filter on ActionColumn : Not working");
      return false;
    }
    if (this.currentFilters[tableName] == null) {
      this.currentFilters[tableName] = {};
    }
    this.currentFilters[tableName][columnName] = $(e.target).val();
    console.log("Current filter:", this.currentFilters);
    this.updateRowData();
    this.updateVisibleText();
    return true;
  };

  TableView.prototype.addMessageRow = function(message) {
    this.rowDataRaw.push(message);
    return 0;
  };

  TableView.prototype.clear = function() {
    return this.elTableHolder.html("");
  };

  TableView.prototype.reset = function() {
    this.elTableHolder.html("");
    this.colList = [];
    return true;
  };

  TableView.prototype.onAddedEvent = function(eventName, callback) {
    var col, m;
    m = eventName.match(/click_(.*)/);
    if ((m != null) && (m[1] != null)) {
      col = this.findColumn(m[1]);
      if (col != null) {
        col.clickable = true;
        this.updateVisibleText();
      }
    }
    return true;
  };

  TableView.prototype.moveCellRight = function() {
    var maxCol, visCol;
    if (this.currentFocusCol == null) {
      return;
    }
    console.log("moveCellRight focus=", this.currentFocusCol, " offset=", this.offsetShowingLeft);
    visCol = this.getTableVisibleCols();
    maxCol = this.getTableTotalCols();
    if (this.offsetShowingLeft + visCol + 1 < maxCol) {
      console.log("Able to move right");
      this.scrollRight(1);
      this.setFocusCell(this.currentFocusRow, this.currentFocusCol);
      return;
    }
    if (this.offsetShowingLeft + this.getTableVisibleCols() + 1 < this.getTableTotalCols()) {
      this.scrollRight(1);
      this.setFocusCell(this.currentFocusRow, this.currentFocusCol);
      return;
    }
    this.setFocusCell(this.currentFocusRow, this.currentFocusCol + 1);
    return true;
  };

  TableView.prototype.moveCellLeft = function() {
    if (this.currentFocusCol == null) {
      return;
    }
    console.log("moveCellLeft focus=", this.currentFocusCol, " offset=", this.offsetShowingLeft);
    if (this.offsetShowingLeft > 0) {
      this.scrollRight(-1);
      this.setFocusCell(this.currentFocusRow, this.currentFocusCol);
      return;
    }
    if (this.currentFocusCol === 0) {
      return;
    }
    this.setFocusCell(this.currentFocusRow, this.currentFocusCol - 1);
    return true;
  };

  TableView.prototype.moveCellUp = function() {
    var lastFocusCol, lastFocusRow;
    lastFocusRow = this.currentFocusRow;
    lastFocusCol = this.currentFocusCol;
    if (this.currentFocusRow == null) {
      return;
    }
    if (this.offsetShowingTop > 0) {
      this.scrollUp(-1);
      this.setFocusCell(this.currentFocusRow, this.currentFocusCol);
      return;
    }
    if (this.currentFocusRow === 0) {
      return;
    }
    if (!this.setFocusCell(this.currentFocusRow - 1, this.currentFocusCol)) {
      this.setFocusCell(lastFocusRow, lastFocusCol);
    }
    return true;
  };

  TableView.prototype.moveCellDown = function() {
    var lastFocusCol, lastFocusRow, maxRow, visRow;
    lastFocusRow = this.currentFocusRow;
    lastFocusCol = this.currentFocusCol;
    if (this.currentFocusRow == null) {
      return;
    }
    visRow = this.getTableVisibleRows();
    maxRow = this.getTableTotalRows();
    if (this.offsetShowingTop + visRow + 1 < maxRow) {
      this.scrollUp(1);
      this.setFocusCell(this.currentFocusRow, this.currentFocusCol);
      return;
    }
    if (this.offsetShowingTop + 1 + this.getTableVisibleRows >= this.getTableVisibleRows()) {
      this.scrollUp(1);
      this.setFocusCell(this.currentFocusRow, this.currentFocusCol);
      return;
    }
    if (!this.setFocusCell(this.currentFocusRow + 1, this.currentFocusCol)) {
      this.setFocusCell(lastFocusRow, lastFocusCol);
    }
    return true;
  };

  TableView.prototype.setFocusFirstCell = function() {
    this.setFocusCell(0, 0);
    return true;
  };

  TableView.prototype.onActionCopyCell = function() {
    var item, parts, path, record_id, source, tableName;
    if (this.currentFocusCell == null) {
      return;
    }
    path = this.currentFocusCell.getDataValue("path");
    if (path != null) {
      parts = path.split("/");
      tableName = parts[1];
      record_id = parts[2];
      source = parts[3];
      item = this.findRowFromPath(path);
      console.log("COPY:", item[source]);
    }
    return true;
  };

  TableView.prototype.setFocusCell = function(visibleRow, visColNum, e) {
    var cellType, colNum, element, item, parts, path, record_id, rowNum, source, tableName, tag_data, tag_id;
    if (!this.allowSelectCell) {
      return false;
    }
    if ((this.currentFocusCell != null) && (this.currentFocusCell.removeClass != null)) {
      this.currentFocusCell.removeClass("cellfocus");
    }
    this.currentFocusCell = null;
    this.currentFocusCol = null;
    this.currentFocusRow = null;
    this.currentFocusPath = null;
    if (visibleRow === null || visColNum === null) {
      this.updateStatusText("Nothing selected");
      return false;
    }
    element = null;
    for (tag_id in globalTagData) {
      tag_data = globalTagData[tag_id];
      if (tag_data.vr === visibleRow && tag_data.vc === visColNum) {
        element = this.elTableHolder.find("[data-id='" + tag_id + "']");
        path = tag_data.path;
        rowNum = tag_data.rn;
        colNum = tag_data.cn;
        console.log("find data-id=" + tag_id + ":", element[0]);
        break;
      }
    }
    if (element == null) {
      console.log("Unable to find element for " + visibleRow + "/" + visibleCol);
      return false;
    }
    if (path != null) {
      this.currentFocusCell = path;
      parts = path.split("/");
      if (parts != null) {
        tableName = parts[1];
        record_id = parts[2];
        source = parts[3];
      }
    }
    cellType = this.getCellType({
      visibleRow: visibleRow,
      visibleCol: visColNum,
      rowNum: rowNum,
      colNum: colNum
    });
    if (source == null) {
      source = this.getCellSource({
        visibleRow: visibleRow,
        visibleCol: visColNum,
        rowNum: rowNum,
        colNum: colNum
      });
    }
    console.log("setFocusCell " + visibleRow + ", " + visColNum + " = " + cellType + " | " + source);
    if ((visibleRow == null) || (visColNum == null) || cellType !== "data") {
      this.updateStatusText("Nothing selected");
      return false;
    }
    this.currentFocusRow = parseInt(visibleRow);
    this.currentFocusCol = parseInt(visColNum);
    if (visibleRow === null || visColNum === null) {
      this.currentFocusRow = null;
      this.currentFocusCol = null;
      this.updateStatusText("Nothing selected");
      return false;
    }
    this.currentFocusCell = this.shadowCells[visibleRow].children[visColNum];
    if (this.currentFocusCell != null) {
      path = this.currentFocusCell.getDataValue("path");
      if (path != null) {
        this.currentFocusPath = path;
        this.currentFocusCell.addClass("cellfocus");
        item = this.findRowFromPath(path);
        this.emitEvent('focus_cell', [path, item]);
        this.updateStatusText(item[source]);
      }
    }
    return true;
  };

  TableView.prototype.findPathVisible = function(path) {
    var cell, idx, j, len1, ref, ref1, shadow;
    ref = this.shadowCells;
    for (idx in ref) {
      shadow = ref[idx];
      ref1 = shadow.children;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        cell = ref1[j];
        if (cell.getDataValue("path") === path) {
          return cell;
        }
      }
    }
    return null;
  };

  TableView.prototype.show = function() {};

  TableView.prototype.hide = function() {};

  TableView.prototype.destroy = function() {};

  TableView.prototype.findColFromPath = function(path) {
    var colName, i, j, keyValue, len1, part, parts, tableName;
    if (path == null) {
      return null;
    }
    parts = path.split('/');
    tableName = parts[1];
    keyValue = parts[2];
    colName = parts[3];
    for (i = j = 0, len1 = parts.length; j < len1; i = ++j) {
      part = parts[i];
      if (i >= 4) {
        colName = colName + '/' + part;
      }
    }
    return colName;
  };

  TableView.prototype.findRowFromPath = function(path) {
    var colName, colNum, data, keyValue, parts, tableName;
    if (path == null) {
      return null;
    }
    parts = path.split('/');
    tableName = parts[1];
    keyValue = parts[2];
    colName = parts[3];
    if (keyValue === "Filter") {
      return "Filter";
    }
    if (keyValue === "Header") {
      return "Header";
    }
    data = {};
    colNum = 0;
    data = DataMap.getDataForKey(this.primaryTableName, keyValue);
    if (data == null) {
      return null;
    }
    data["id"] = keyValue;
    return data;
  };

  TableView.prototype.getColumnType = function(colName) {
    var actionCol, dataCol, index, j, len1, ref, ref1;
    ref = this.colByNum;
    for (index in ref) {
      dataCol = ref[index];
      if (dataCol.getSource() === colName) {
        return 1;
      }
    }
    ref1 = this.actionColList;
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      actionCol = ref1[j];
      if (actionCol.getSource() === colName) {
        return 2;
      }
    }
    return 0;
  };

  TableView.prototype.ungroupColumn = function(colName) {
    var col, columns, j, len1;
    columns = DataMap.getColumnsFromTable(this.primaryTableName, this.columnReduceFunction);
    for (j = 0, len1 = columns.length; j < len1; j++) {
      col = columns[j];
      if (col.getSource() === colName) {
        col.isGrouped = false;
        return true;
      }
    }
    return false;
  };

  return TableView;

})();
var initializeSimpleTooltips, setupSimpleTooltips, simpleTooltipTimer;

window.globalHoverTimer = 0;

window.globalHoverElement = 0;

window.elSimpleTooltip = 0;

window.elSimpleIndicator = 0;

initializeSimpleTooltips = function() {
  $("body").append($("<i>", {
    "class": "fa fa-lightbulb-o",
    id: "simpleTooltipIndicator"
  }));
  $("body").append($("<div>", {
    "class": "simpleTooltip",
    id: "simpleTooltip"
  }));
  window.elSimpleTooltip = $("#simpleTooltip");
  return window.elSimpleIndicator = $("#simpleTooltipIndicator");
};

simpleTooltipTimer = function() {
  var pos, title, x, y;
  title = window.globalHoverElement.attr("data-title");
  pos = window.globalHoverElement.position();
  window.elSimpleTooltip.html(title).show();
  x = pos.left + (window.globalHoverElement.width() / 2) - (window.elSimpleTooltip.width() / 2);
  y = pos.top - 10 - window.globalHoverElement.height() - 40;
  if (x < 0) {
    x = 0;
  }
  if (x + window.globalHoverElement.width() > $(window).width()) {
    x = $(window).width - 10 - window.globalHoverElement.width();
  }
  return window.elSimpleTooltip.show().css({
    left: x,
    top: y
  });
};

setupSimpleTooltips = function() {
  if (window.elSimpleTooltip === 0) {
    initializeSimpleTooltips();
  }
  return $("body").find('[tooltip="simple"]').each(function(idx, el) {
    var $el, tooltipID;
    $el = $(el);
    tooltipID = $el.attr("data-id-tooltip");
    if (!tooltipID) {
      tooltipID = GlobalValueManager.NextGlobalID();
      $el.attr("data-id-tooltip", tooltipID);
      $el.on('mouseover', function(e) {
        window.elSimpleIndicator.show();
        if (window.globalHoverTimer) {
          clearTimeout(window.globalHoverTimer);
        }
        window.globalHoverElement = $(e.target);
        window.globalHoverTimer = setTimeout(simpleTooltipTimer, 1000);
        return true;
      });
      return $el.on('mouseout', function(e) {
        window.elSimpleIndicator.hide();
        if (window.globalHoverTimer) {
          clearTimeout(window.globalHoverTimer);
        }
        window.elSimpleTooltip.hide();
        return true;
      });
    }
  });
};
var VirtualScrollArea,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

VirtualScrollArea = (function() {
  function VirtualScrollArea(holderElement, isVert1, otherScrollBar) {
    var className, isVert;
    this.isVert = isVert1;
    this.otherScrollBar = otherScrollBar;
    this.resize = bind(this.resize, this);
    this.width = bind(this.width, this);
    this.height = bind(this.height, this);
    this.show = bind(this.show, this);
    this.hide = bind(this.hide, this);
    this.setupEvents = bind(this.setupEvents, this);
    this.onScrollTrackMouseDown = bind(this.onScrollTrackMouseDown, this);
    this.onMarkerDragFinished = bind(this.onMarkerDragFinished, this);
    this.onMarkerDrag = bind(this.onMarkerDrag, this);
    this.OnMarkerSet = bind(this.OnMarkerSet, this);
    this.setPos = bind(this.setPos, this);
    this.setRange = bind(this.setRange, this);
    GlobalClassTools.addEventManager(this);
    this.min = 0;
    this.max = 0;
    this.current = 0;
    this.visible = true;
    this.bottomPadding = 0;
    this.rightPadding = 0;
    this.mySize = 20;
    this.backColor = "#F0F0F0";
    this.borderColor = "1px solid #E7E7E7";
    if ((this.isVert == null) || !this.isVert) {
      isVert = false;
    }
    if (typeof holderElement === "object" && (holderElement.el != null)) {
      this.elHolder = holderElement.el;
    } else if (typeof holderElement === "string") {
      this.elHolder = $("#" + holderElement.replace("#", ""));
    } else {
      this.elHolder = $(holderElement);
    }
    className = "horiz";
    if (this.isVert) {
      className = "vert";
    }
    this.elScrollTrack = new WidgetTag("div", "vscroll " + className);
    this.thumb = this.elScrollTrack.add("div", "marker");
    this.elHolder.css({
      '-moz-user-select': 'none',
      '-webkit-user-select': 'none',
      'user-select': 'none'
    });
    this.elHolder.append(this.elScrollTrack.el);
    this.resize();
    this.setupEvents();
  }

  VirtualScrollArea.prototype.setRange = function(newMin, newMax, newDisplaySize, newCurrent) {
    var result, updated;
    updated = false;
    if ((newMin == null) || (newMax == null) || (newDisplaySize == null) || (newCurrent == null)) {
      return false;
    }
    if (newMin !== this.min) {
      this.min = newMin;
      updated = true;
    }
    if (newMax !== this.max) {
      this.max = newMax;
      updated = true;
    }
    if (newDisplaySize !== this.displaySize) {
      this.displaySize = newDisplaySize;
      updated = true;
    }
    if (newCurrent !== this.current) {
      this.current = newCurrent;
      updated = true;
    }
    if (updated === false) {
      return false;
    }
    result = false;
    if (this.displaySize >= (this.max - this.min)) {
      return this.hide();
    } else {
      if (this.visible === false) {
        result = true;
      }
      this.show();
    }
    if (this.height() === 0 || this.width() === 0) {
      setTimeout((function(_this) {
        return function() {
          _this.current = -1;
          return _this.setRange(newMin, newMax, newDisplaySize, newCurrent);
        };
      })(this), 10);
    } else {
      if (this.max - this.min < 1) {
        this.spacing = 0;
      } else if (this.isVert) {
        this.spacing = this.height() / (this.max - this.min);
      } else {
        this.spacing = this.width() / (this.max - this.min);
      }
      this.setPos(this.current);
    }
    return result;
  };

  VirtualScrollArea.prototype.setPos = function(current) {
    var newOffset, newWidth;
    this.current = current;
    newOffset = this.spacing * this.current;
    newWidth = this.spacing * this.displaySize;
    newWidth = Math.floor(newWidth);
    if (this.isVert) {
      this.thumb.el.css("height", newWidth);
      this.thumb.el.css("top", newOffset);
    } else {
      newOffset = this.spacing * this.current;
      this.thumb.el.css("left", newOffset);
      this.thumb.el.css("width", newWidth);
    }
    return true;
  };

  VirtualScrollArea.prototype.OnMarkerSet = function(pos, maxLoc) {
    var num, percent;
    percent = pos / (maxLoc - this.thumbHeight);
    num = this.min + (percent * (this.max - this.min));
    console.log("num ==== ", num);
    this.emitEvent("scroll_to", [Math.floor(num)]);
    return true;
  };

  VirtualScrollArea.prototype.onMarkerDrag = function(diffX, diffY) {
    var amount;
    if (this.isVert) {
      amount = diffY / this.spacing;
    } else {
      amount = diffX / this.spacing;
    }
    amount = this.dragCurrent + amount;
    if (amount < 1) {
      amount = 0;
    }
    if (amount + this.displaySize >= this.max) {
      amount = this.max - this.displaySize;
    }
    amount = Math.floor(amount);
    this.emitEvent("scroll_to", [Math.floor(amount)]);
    return true;
  };

  VirtualScrollArea.prototype.onMarkerDragFinished = function(diffX, diffY, e) {
    return true;
  };

  VirtualScrollArea.prototype.onScrollTrackMouseDown = function(e) {
    var pos;
    pos = this.elHolder.offset();
    if (e.target.className === "marker") {
      this.dragCurrent = Math.floor(this.current);
      GlobalMouseDrag.startDrag(e, this.onMarkerDrag, this.onMarkerDragFinished);
    } else {
      if (this.isVert) {
        if (e.offsetY < 10) {
          e.offsetY = 0;
        }
        this.OnMarkerSet(e.offsetY, this.height());
      } else {
        if (e.offsetX < 10) {
          e.offsetX = 0;
        }
        this.OnMarkerSet(e.offsetX, this.width());
      }
    }
    return true;
  };

  VirtualScrollArea.prototype.setupEvents = function() {
    this.thumbHeight = 18;
    this.document = $(document);
    if (this.isVert) {
      this.thumb.el.css({
        height: this.thumbHeight,
        width: this.thumbHeight - 2
      });
    } else {
      this.thumb.el.css({
        width: this.thumbHeight,
        height: this.thumbHeight - 2
      });
    }
    this.elScrollTrack.el.on("mousedown", this.onScrollTrackMouseDown);
    return this.elHolder.on("wheel", (function(_this) {
      return function(e) {
        var deltaX, deltaY, scrollX, scrollY;
        if (!_this.visible) {
          return true;
        }
        if (e.originalEvent.deltaMode === e.originalEvent.DOM_DELTA_LINE) {
          deltaX = e.originalEvent.deltaX * -5;
          deltaY = e.originalEvent.deltaY * -5;
        } else {
          deltaX = e.originalEvent.deltaX * -1;
          deltaY = e.originalEvent.deltaY * -1;
        }
        scrollX = Math.ceil(Math.abs(deltaX) / 60);
        scrollY = Math.ceil(Math.abs(deltaY) / 60);
        console.log("deltaX == ", deltaX);
        if (scrollY > 3) {
          scrollX = 0;
        }
        e.preventDefault();
        e.stopPropagation();
        if (_this.isVert && scrollY !== 0) {
          if (e.originalEvent.wheelDelta < 0) {
            _this.emitEvent("scroll_to", [_this.current + scrollY]);
          } else {
            _this.emitEvent("scroll_to", [_this.current - scrollY]);
          }
        }
        if (!_this.isVert && scrollX !== 0) {
          if (e.originalEvent.wheelDelta < 0) {
            _this.emitEvent("scroll_to", [_this.current + scrollX]);
          } else {
            _this.emitEvent("scroll_to", [_this.current + scrollX]);
          }
        }
        return true;
      };
    })(this));
  };

  VirtualScrollArea.prototype.hide = function() {
    if (this.visible === false) {
      return false;
    }
    this.visible = false;
    this.parentHeight = null;
    this.parentWidth = null;
    this.elScrollTrack.el.hide();
    return true;
  };

  VirtualScrollArea.prototype.show = function() {
    this.visible = true;
    this.parentHeight = null;
    this.parentWidth = null;
    this.elScrollTrack.el.show();
    return true;
  };

  VirtualScrollArea.prototype.height = function() {
    if ((this.parentHeight != null) && this.parentHeight > 0) {
      return this.parentHeight;
    }
    this.parentHeight = this.elHolder.height();
    return this.parentHeight;
  };

  VirtualScrollArea.prototype.width = function() {
    if ((this.oarentWidth != null) && this.parentWidth > 0) {
      return this.parentWidth;
    }
    this.parentWidth = this.elHolder.width();
    return this.parentWidth;
  };

  VirtualScrollArea.prototype.resize = function() {
    this.parentHeight = null;
    this.parentWidth = null;
    this.elScrollTrack.el.css({
      position: "absolute",
      border: this.borderColor,
      backgroundColor: this.backColor,
      fontSize: "10px",
      padding: "2px"
    });
    if (this.isVert) {
      this.elScrollTrack.el.css({
        right: this.rightPadding,
        top: 0,
        bottom: this.bottomPadding,
        width: this.mySize
      });
    } else {
      this.elScrollTrack.el.css({
        right: this.rightPadding,
        bottom: this.bottomPadding,
        left: 0,
        height: this.mySize
      });
    }
    return true;
  };

  return VirtualScrollArea;

})();
var DynamicTabs,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

DynamicTabs = (function() {
  function DynamicTabs(holderElement) {
    this.onCheckTableUpdateRowcount = bind(this.onCheckTableUpdateRowcount, this);
    this.doAddTableTab = bind(this.doAddTableTab, this);
    this.doAddTableTabData = bind(this.doAddTableTabData, this);
    this.doAddViewTab = bind(this.doAddViewTab, this);
    this.doAddViewTabData = bind(this.doAddViewTabData, this);
    this.updateTabs = bind(this.updateTabs, this);
    this.onResize = bind(this.onResize, this);
    this.refreshTagOrders = bind(this.refreshTagOrders, this);
    this.addSortedTags = bind(this.addSortedTags, this);
    this.addTabData = bind(this.addTabData, this);
    this.addTab = bind(this.addTab, this);
    this.getTab = bind(this.getTab, this);
    this.show = bind(this.show, this);
    this.getActiveTab = bind(this.getActiveTab, this);
    this.onClickTab = bind(this.onClickTab, this);
    this.tags = {};
    this.tabs = {};
    this.tabCount = 0;
    this.activeTab = null;
    this.elHolder = new WidgetTag("div", "ninja-tabs");
    this.tabList = this.elHolder.add("ul", "ninja-tab-list");
    this.elHolder.addDiv("clr");
    this.tabContent = this.elHolder.add("div", "ninja-tab-content tab-content");
    this.tabData = [];
    $(holderElement).append(this.elHolder.el);
    GlobalClassTools.addEventManager(this);
    globalTableEvents.on("row_count", this.onCheckTableUpdateRowcount);
  }

  DynamicTabs.prototype.onSetBadge = function(num, classname) {
    var id;
    id = this.id;
    this.parent.tags[id].badge = num;
    this.parent.tags[id].badgeText.addClass(classname);
    return this.parent.updateTabs();
  };

  DynamicTabs.prototype.onClickTab = function(e) {
    console.log("dnymictabs onClicktab");
    if ((e != null) && (e.path != null)) {
      this.show(e.path);
    }
    return true;
  };

  DynamicTabs.prototype.getActiveTab = function() {
    return this.tags[this.activeTab];
  };

  DynamicTabs.prototype.show = function(id) {
    console.log("dynamic tabs show " + id);
    if (id == null) {
      return false;
    }
    if (typeof id === "object" && (id.id != null)) {
      id = id.id;
    }
    if (this.tags[id] != null) {
      this.emitEvent("showtab", [id, this.tags[id]]);
      this.activeTab = id;
      this.updateTabs();
    } else {
      console.log("Warning: DynamicTabs show(" + id + ") invalid tab");
    }
    return true;
  };

  DynamicTabs.prototype.getTab = function(tabName) {
    if (this.tabs[tabName] != null) {
      return this.tabs[tabName];
    }
    return null;
  };

  DynamicTabs.prototype.addTab = function(tabName, defaultHtml) {
    var elBody, elTab, elTabBadge, elTabText, id;
    if (this.tabs[tabName] != null) {
      return this.tabs[tabName];
    }
    id = "tab" + (this.tabCount++);
    elTab = this.tabList.add("li", "ninja-nav-tab");
    elTab.setDataPath(id);
    elTab.on("click", this.onClickTab);
    elTabText = elTab.add("div", "ninja-tab-text");
    elTabText.html(tabName);
    elTabBadge = elTab.addDiv("ninja-badge");
    elBody = this.tabContent.add("div", "ninja-nav-body");
    elBody.html(defaultHtml);
    if (this.activeTab == null) {
      this.activeTab = id;
    }
    this.tags[id] = {
      name: tabName,
      id: id,
      parent: this,
      tab: elTab,
      body: elBody,
      tabText: elTabText,
      badgeText: elTabBadge,
      setBadge: this.onSetBadge,
      show: (function(_this) {
        return function() {
          _this.activeTab = id;
          return _this.updateTabs();
        };
      })(this)
    };
    this.tabs[tabName] = this.tags[id];
    this.updateTabs();
    return this.tags[id];
  };

  DynamicTabs.prototype.addTabData = function(tabName, defaultHtml, order) {
    var tab;
    if (order == null) {
      order = -1;
    }
    tab = {
      tabName: tabName,
      defaultHtml: defaultHtml,
      order: order
    };
    this.tabData.push(tab);
    return tab;
  };

  DynamicTabs.prototype.addSortedTags = function*(tabType) {
    var i, index, j, k, len, len1, len2, sortedTags, tag;
    sortedTags = this.tabData.sort(this.sorter);
    this.refreshTagOrders(sortedTags);
    if (tabType === "tab") {
      for (index = i = 0, len = sortedTags.length; i < len; index = ++i) {
        tag = sortedTags[index];
        this.addTab(tag.tabName, tag.defaultHtml);
      }
    } else if (tabType === "viewTab") {
      for (index = j = 0, len1 = sortedTags.length; j < len1; index = ++j) {
        tag = sortedTags[index];
        yield this.doAddViewTab(tag.viewName, tag.tabText, tag.callbackWithView);
      }
    } else if (tabType === "tableTab") {
      for (index = k = 0, len2 = sortedTags.length; k < len2; index = ++k) {
        tag = sortedTags[index];
        yield this.doAddTableTab(tag.tableName, tag.tabText);
      }
    } else {
      console.log("Unsupported Tab Type");
      return;
    }
    return sortedTags;
  };

  DynamicTabs.prototype.refreshTagOrders = function(arrayToOrder) {
    if (!arrayToOrder.length) {
      return;
    }
    if (arrayToOrder[0].order < 0) {
      arrayToOrder[0].order = 0;
    }
    arrayToOrder.reduce(function(prevOrder, current) {
      if (prevOrder.order != null) {
        prevOrder = prevOrder.order;
      }
      if (current.order < 0) {
        current.order = prevOrder != null ? prevOrder + 1 : 0;
      }
      if (prevOrder >= current.order) {
        current.order = prevOrder + 1;
      }
      return current.order;
    });
    return arrayToOrder;
  };

  DynamicTabs.prototype.sorter = function(a, b) {
    if (a.order >= 0 && b.order >= 0) {
      if (a.order > b.order) {
        return 1;
      } else if (a.order < b.order) {
        return -1;
      } else {
        return 1;
      }
    } else if (a.order === b.order) {
      return 0;
    } else if (a.order < 0) {
      return 1;
    } else {
      return -1;
    }
  };

  DynamicTabs.prototype.onResize = function(w, h) {};

  DynamicTabs.prototype.updateTabs = function() {
    var id, ref, tag;
    ref = this.tags;
    for (id in ref) {
      tag = ref[id];
      if (id === this.activeTab) {
        tag.tab.addClass("active");
        tag.body.show();
        if (tag.body.onResize != null) {
          tag.body.onResize(-1, -1);
        }
        setTimeout(function() {
          var h, w;
          w = $(window).width();
          h = $(window).height();
          return globalTableEvents.emitEvent("resize", [w, h]);
        }, 10);
      } else {
        tag.tab.removeClass("active");
        tag.body.hide();
      }
      if (tag.badge != null) {
        tag.badgeText.html(tag.badge);
        tag.badgeText.show();
      } else {
        tag.badgeText.hide();
      }
    }
    return true;
  };

  DynamicTabs.prototype.doAddViewTabData = function(viewName, tabText, callbackWithView, order) {
    var viewTab;
    if (order == null) {
      order = -1;
    }
    viewTab = {
      viewName: viewName,
      tabText: tabText,
      callbackWithView: callbackWithView,
      order: order
    };
    this.tabData.push(viewTab);
    return viewTab;
  };

  DynamicTabs.prototype.doAddViewTab = function(viewName, tabText, callbackWithView) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        var content, elViewHolder, gid, tab;
        gid = GlobalValueManager.NextGlobalID();
        content = "<div id='tab_" + gid + "' class='tab_content'></div>";
        tab = _this.addTab(tabText, content);
        elViewHolder = $("#tab_" + gid);
        return doAppendView(viewName, elViewHolder).then(function(view) {
          view.elHolder = elViewHolder;
          callbackWithView(view, tabText);
          return resolve(tab);
        });
      };
    })(this));
  };

  DynamicTabs.prototype.doAddTableTabData = function(tableName, tabText, order) {
    var tableTab;
    if (order == null) {
      order = -1;
    }
    tableTab = {
      tableName: tableName,
      tabText: tabText,
      order: order
    };
    this.tabData.push(tableTab);
    return tableTab;
  };

  DynamicTabs.prototype.doAddTableTab = function(tableName, tabText) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.doAddViewTab("Table", tabText, function(view, viewText) {
          var table;
          if (_this.tables == null) {
            _this.tables = {};
          }
          table = view.loadTable(tableName);
          table.showCheckboxes = true;
          table.setStatusBarEnabled();
          _this.tables[tableName] = table;
          _this.tables[tableName].tab = _this.tabs[tabText];
          return _this.tabs[tabText].table = table;
        }).then(function(tab) {
          return resolve(_this.tabs[tabText]);
        });
      };
    })(this));
  };

  DynamicTabs.prototype.onCheckTableUpdateRowcount = function(tableName, newRowCount) {
    if (this.tables == null) {
      return;
    }
    if (this.tables[tableName] != null) {
      this.tables[tableName].tab.badgeText.html(newRowCount);
      this.tables[tableName].tab.badgeText.show();
      this.tables[tableName].tab.badge = newRowCount;
    }
    return true;
  };

  return DynamicTabs;

})();
var GlobalClassTools;

String.prototype.ucwords = function() {
  var str;
  str = this.toLowerCase();
  return str.replace(/(^([a-zA-Z\p{M}]))|([ -][a-zA-Z\p{M}])/g, function($1) {
    return $1.toUpperCase();
  });
};

window.newPromise = function(callFunction, context) {
  return new Promise(function(resolve, reject) {
    if (callFunction == null) {
      resolve(true);
    }
    return co(callFunction).call(context || this, function(err, value) {
      if (err) {
        console.log("ERR:", err);
        reject(err);
      }
      return resolve(value);
    });
  });
};

window.copyToClipboard = function(data) {
  var el;
  el = document.getElementById("clipboardHolder");
  if (el == null) {
    $("body").append("<input id='clipboardHolder'></input>");
    el = document.getElementById("clipboardHolder");
  }
  $(el).show();
  $(el).val(data);
  $(el).select();
  document.execCommand("copy");
  $(el).blur();
  $(el).hide();
};

GlobalClassTools = (function() {
  function GlobalClassTools() {}

  GlobalClassTools.addEventManager = function(classObj) {
    classObj.eventManager = new EvEmitter();
    classObj.on = function(eventName, callback) {
      if (eventName !== "added_event") {
        this.eventManager.emitEvent("added_event", [eventName, callback]);
      }
      return this.eventManager.on(eventName, callback);
    };
    classObj.off = function(eventName, callback) {
      return this.eventManager.off(eventName, callback);
    };
    classObj.once = function(eventName, callback) {
      return this.eventManager.once(eventName, callback);
    };
    classObj.emitEvent = function(eventName, args) {
      if (!Array.isArray(args)) {
        args = [args];
      }
      return this.eventManager.emitEvent(eventName, args);
    };
    return true;
  };

  return GlobalClassTools;

})();
var GlobalMouseDrag, globalMouseDrag,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

globalMouseDrag = null;

GlobalMouseDrag = (function() {
  function GlobalMouseDrag() {
    this.onMouseUp = bind(this.onMouseUp, this);
    this.onMouseMove = bind(this.onMouseMove, this);
  }

  GlobalMouseDrag.prototype.onMouseMove = function(e) {
    var diffX, diffY;
    diffX = e.pageX - this.globalDragStartX;
    diffY = e.pageY - this.globalDragStartY;
    if (this.onChange != null) {
      this.onChange(diffX, diffY, e);
    }
    return false;
  };

  GlobalMouseDrag.prototype.onMouseUp = function(e) {
    var diffX, diffY;
    diffX = e.pageX - this.globalDragStartX;
    diffY = e.pageY - this.globalDragStartY;
    if (this.onFinished != null) {
      this.onFinished(diffX, diffY, e);
    }
    globalMouseDrag.document.off("mousemove touchmove pointermove", globalMouseDrag.onMouseMove);
    $(globalMouseDrag.target).removeClass("dragging");
    delete globalMouseDrag.target;
    delete globalMouseDrag.onChange;
    delete globalMouseDrag.onFinished;
    return false;
  };

  GlobalMouseDrag.startDrag = function(e, dragMove, dragFinished) {
    if (globalMouseDrag === null) {
      globalMouseDrag = new GlobalMouseDrag();
      globalMouseDrag.document = $(document);
    }
    globalMouseDrag.target = e.target;
    globalMouseDrag.globalDragStartX = e.pageX;
    globalMouseDrag.globalDragStartY = e.pageY;
    globalMouseDrag.onChange = dragMove;
    globalMouseDrag.onFinished = dragFinished;
    globalMouseDrag.document.on("mousemove touchmove pointermove", globalMouseDrag.onMouseMove);
    globalMouseDrag.document.one("mouseup touchend pointerup", globalMouseDrag.onMouseUp);
    $(e.target).addClass("dragging");
    return false;
  };

  return GlobalMouseDrag;

})();
var GlobalValueManager, l, reDateUtc;

l = console.log;

reDateUtc = /\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\d\d\dZ/;

GlobalValueManager = (function() {
  function GlobalValueManager() {}

  GlobalValueManager.globalCellID = 0;

  GlobalValueManager.globalData = {};

  GlobalValueManager.NextGlobalID = function() {
    var gid;
    gid = GlobalValueManager.globalCellID++;
    return gid;
  };

  GlobalValueManager.SetGlobal = function(gid, obj) {
    GlobalValueManager.globalData[gid] = obj;
    return gid;
  };

  GlobalValueManager.GetGlobal = function(gid) {
    return GlobalValueManager.globalData[gid];
  };

  GlobalValueManager.GetLoading = function() {
    return "<i class='fa fa-3x fa-asterisk fa-spin'></i>";
  };

  GlobalValueManager.GetCoordsFromEvent = function(e) {
    var clickX, clickY, values;
    clickX = 0;
    clickY = 0;
    if ((e.clientX || e.clientY) && document.body && document.body.scrollLeft !== null) {
      clickX = e.clientX + document.body.scrollLeft;
      clickY = e.clientY + document.body.scrollTop;
    }
    if ((e.clientX || e.clientY) && document.compatMode === 'CSS1Compat' && document.documentElement && document.documentElement.scrollLeft !== null) {
      clickX = e.clientX + document.documentElement.scrollLeft;
      clickY = e.clientY + document.documentElement.scrollTop;
    }
    if (e.pageX || e.pageY) {
      clickX = e.pageX;
      clickY = e.pageY;
    }
    values = {};
    values.x = clickX;
    values.y = clickY;
    return values;
  };

  GlobalValueManager.GetNumber = function(a, b, c, d) {
    var value;
    if (typeof a !== "undefined" && a !== null) {
      value = parseInt(a);
      if (value) {
        return value;
      }
    }
    if (typeof b !== "undefined" && b !== null) {
      value = parseInt(b);
      if (value) {
        return value;
      }
    }
    if (typeof c !== "undefined" && c !== null) {
      value = parseInt(c);
      if (value) {
        return value;
      }
    }
    if (typeof d !== "undefined" && d !== null) {
      value = parseInt(d);
      if (value) {
        return value;
      }
    }
    return 0;
  };

  GlobalValueManager.GetMoment = function(date) {
    var e;
    try {
      if (date === null) {
        return null;
      }
      if ((date != null) && typeof date === "object" && (date.getTime != null)) {
        return moment(date);
      }
      if (typeof date !== "string") {
        return null;
      }
      if (reDateUtc.test(date)) {
        return moment(date);
      }
      date = date.replace("T", " ");
      if (date.match(/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/)) {
        return moment(date, "YYYY-MM-DD HH:mm:ss");
      }
      if (date.match(/\d\d\d\d.\d\d.\d\d/)) {
        return moment(date, "YYYY-MM-DD");
      }
      if (date.match(/\d\d-\d\d-\d\d\d\d/)) {
        return moment(date, "MM-DD-YYYY");
      }
    } catch (error) {
      e = error;
      console.log("Unable to get date from:", e);
    }
    return null;
  };

  GlobalValueManager.DaysAgo = function(stamp) {
    var age, m;
    m = GlobalValueManager.GetMoment(stamp);
    if (m === null) {
      return 0;
    }
    age = moment().diff(stamp);
    age = Math.trunc(age / 86400000);
    if (age === 1) {
      return "1 day";
    }
    return age + " days";
  };

  GlobalValueManager.DateFormat = function(stamp) {
    var age, html;
    if (stamp === null) {
      if (val) {
        return val;
      }
      return "&mdash;";
    }
    html = "<span class='fdate'>" + stamp.format("MM/DD/YYYY") + "</span>";
    age = moment().diff(stamp);
    age = age / 86400000;
    if (age < 401) {
      age = numeral(age).format("#") + " d";
    } else if (age < 365 * 2) {
      age = numeral(age / 30.5).format("#") + " mn";
    } else {
      age = numeral(age / 365).format("#.#") + " yrs";
    }
    return html += "<span class='fage'>" + age + "</span>";
  };

  GlobalValueManager.DateTimeFormat = function(stamp) {
    var age, hrs, html, min;
    if (stamp === null) {
      return "&mdash;";
    }
    html = "<span class='fdate'>" + stamp.format("dddd, MMMM Do YYYY, h:mm:ss a") + "</span>";
    age = moment().diff(stamp);
    age = age / 86400000;
    if (age < 1) {
      hrs = age * 24;
      if (hrs > 3) {
        age = numeral(hrs).format("#") + " hours";
      } else {
        min = age * (24 * 60);
        age = numeral(min).format("#") + " minutes";
      }
    } else if (age < 401) {
      age = numeral(age).format("#") + " days";
    } else if (age < 365 * 2) {
      age = numeral(age / 30.5).format("#") + " months";
    } else {
      age = numeral(age / 365).format("#.#") + " years";
    }
    return html += "<span class='fage'>" + age + "</span>";
  };

  GlobalValueManager.Ucwords = function(str) {
    return (str + '').replace(/^([a-z\u00E0-\u00FC])|\s+([a-z\u00E0-\u00FC])/g, function($1) {
      return $1.toUpperCase();
    });
  };

  GlobalValueManager.Trigger = function(eventName, dataObject) {
    $("body").trigger(eventName, dataObject);
    return true;
  };

  return GlobalValueManager;

})();

this.Watch = function(eventName, delegate) {
  $("body").on(eventName, delegate);
  return true;
};
var WidgetSplittable,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

WidgetSplittable = (function() {
  WidgetSplittable.prototype.validProperties = ["sizes", "minSize", "direction", "gutterSize", "snapOffset", "cursor", "elementStyle", "gutterStyle", "onDrag", "onDragStart", "onDragEnd"];

  WidgetSplittable.prototype.validDirections = ["horizontal", "vertical"];

  function WidgetSplittable(elementHolder) {
    this.elementHolder = elementHolder;
    this.getSecondChild = bind(this.getSecondChild, this);
    this.getFirstChild = bind(this.getFirstChild, this);
    this.render = bind(this.render, this);
    this.checkValidData = bind(this.checkValidData, this);
    this.setData = bind(this.setData, this);
    this.splitData = {};
    this.gid = GlobalValueManager.NextGlobalID();
    true;
  }

  WidgetSplittable.prototype.setData = function(data) {
    var i, len, prop, ref;
    if (!this.checkValidData(data)) {
      return false;
    }
    ref = this.validProperties;
    for (i = 0, len = ref.length; i < len; i++) {
      prop = ref[i];
      this.splitData[prop] = data[prop];
    }
    this.element1 = new WidgetTag("div", "split", "split_1" + this.gid);
    this.element1.appendTo(this.elementHolder);
    this.element2 = new WidgetTag("div", "split", "split_2" + this.gid);
    this.element2.appendTo(this.elementHolder);
    return true;
  };

  WidgetSplittable.prototype.checkValidData = function(data) {
    if (!window.Split) {
      console.log("Error: Plugin Split not loaded");
    }
    if (this.validDirections.indexOf(data.direction) === -1) {
      return false;
    }
    return true;
  };

  WidgetSplittable.prototype.render = function(data) {
    var direction;
    if (!this.setData(data)) {
      return false;
    }
    direction = this.splitData.direction;
    this.element1.addClass("split-" + direction);
    this.element2.addClass("split-" + direction);
    Split(["#" + this.element1.id, "#" + this.element2.id], this.splitData);
    return true;
  };

  WidgetSplittable.prototype.getFirstChild = function() {
    return this.element1;
  };

  WidgetSplittable.prototype.getSecondChild = function() {
    return this.element2;
  };

  return WidgetSplittable;

})();
var PopUpFormWrapper,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

PopUpFormWrapper = (function(superClass) {
  extend(PopUpFormWrapper, superClass);

  function PopUpFormWrapper() {

    /*
    		 * @property [Array] fields the collection of fields to show
    		@fields = []
    
    		 * @property [String] gid the unique key for the current form
    		@gid = "form" + GlobalValueManager.NextGlobalID()
     */
    PopUpFormWrapper.__super__.constructor.call(this);
  }

  PopUpFormWrapper.templateFormFieldText = Handlebars.compile('<div class="form-group">\n	<label for="{{fieldName}}" class="col-md-3 control-label"> {{label}} </label>\n	<div class="col-md-9">\n	  <input type="{{type}}" class="form-control" id="{{fieldName}}" value="{{value}}" name="{{fieldName}}"\n                                                            {{#each attrs}}\n                                                              {{@key}}="{{this}}"\n                                                            {{/each}}\n                                                            />\n                                                            <div id="{{fieldName}}error" class="text-danger help-block"></div>\n                                                          </div>\n</div>');

  PopUpFormWrapper.templateFormFieldSelect = Handlebars.compile('<div class="form-group">\n	<label for="{{fieldName}}" class="col-md-3 control-label"> {{label}} </label>\n	<div class="col-md-9">\n	  <select class="form-control" id="{{fieldName}}" name="{{fieldName}}">\n                                                                {{#each attrs.options}}\n                                                                  <option value="{{this}}" {{#if @first}} selected="selected" {{/if}}>{{this}}</option>\n                                                                {{/each}}\n                                                              </select>\n                                                              <div id="{{fieldName}}error" class="text-danger help-block"></div>\n                                                            </div>\n</div>');

  return PopUpFormWrapper;

})(FormWrapper);
var DataFormatBoolean, DataFormatCurrency, DataFormatDate, DataFormatDateAge, DataFormatDateTime, DataFormatDistance, DataFormatDuration, DataFormatEnum, DataFormatFloat, DataFormatImageList, DataFormatInt, DataFormatLink, DataFormatMemo, DataFormatMultiselect, DataFormatNumber, DataFormatPercent, DataFormatSimpleObject, DataFormatSourceCode, DataFormatTags, DataFormatText, DataFormatTimeAgo, DataFormatterType, e, globalDataFormatter,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

DataFormatterType = (function() {
  function DataFormatterType() {
    this.renderTooltip = bind(this.renderTooltip, this);
    this.openEditor = bind(this.openEditor, this);
    this.onGlobalMouseDown = bind(this.onGlobalMouseDown, this);
    this.appendEditor = bind(this.appendEditor, this);
    this.saveValue = bind(this.saveValue, this);
    this.editData = bind(this.editData, this);
    this.allowKey = bind(this.allowKey, this);
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
  }

  DataFormatterType.prototype.name = "";

  DataFormatterType.prototype.width = null;

  DataFormatterType.prototype.editorShowing = false;

  DataFormatterType.prototype.editorPath = "";

  DataFormatterType.prototype.align = null;

  DataFormatterType.prototype.format = function(data, options, path) {
    return null;
  };

  DataFormatterType.prototype.unformat = function(data, path) {
    return null;
  };

  DataFormatterType.prototype.allowKey = function(keyCode) {
    return true;
  };

  DataFormatterType.prototype.editData = function(parentElement, currentValue, path, onSaveCallback) {
    var elParent, height, left, pos, top, width;
    this.onSaveCallback = onSaveCallback;
    left = 0;
    top = 0;
    width = 100;
    height = 40;
    elParent = null;
    this.editorPath = path;
    if (parentElement != null) {
      elParent = $(parentElement);
      pos = elParent.position();
      left = pos.left;
      top = pos.top;
      width = elParent.outerWidth(false);
      height = elParent.outerHeight(false);
      left = elParent.offset().left;
      top = elParent.offset().top;
    }
    this.editorShowing = true;
    return this.openEditor(elParent, left, top, width, height, currentValue, path);
  };

  DataFormatterType.prototype.saveValue = function(newValue) {
    newValue = this.unformat(newValue, this.editorPath);
    if (this.onSaveCallback != null) {
      this.onSaveCallback(this.editorPath, newValue);
    }
    return true;
  };

  DataFormatterType.prototype.appendEditor = function() {
    $("body").append(this.elEditor);
    this.elEditor.on("blur", (function(_this) {
      return function(e) {
        if (_this.editorShowing) {
          console.log("blurred", e);
          _this.editorShowing = false;
          e.preventDefault();
          e.stopPropagation();
          _this.elEditor.hide();
          return true;
        }
        return false;
      };
    })(this));
    this.elEditor.on("keydown", (function(_this) {
      return function(e) {
        if (e.keyCode === 9) {
          _this.saveValue(_this.elEditor.val());
          _this.editorShowing = false;
          _this.elEditor.hide();
          return false;
        }
        if (e.keyCode === 13) {
          _this.saveValue(_this.elEditor.val());
          _this.editorShowing = false;
          _this.elEditor.hide();
          return false;
        }
        if (e.keyCode === 27) {
          _this.editorShowing = false;
          _this.elEditor.hide();
          return false;
        }
        if (_this.allowKey(e.keyCode)) {
          return true;
        } else {
          return false;
        }
      };
    })(this));
    return $("document").on("click", (function(_this) {
      return function(e) {
        return console.log("Click");
      };
    })(this));
  };

  DataFormatterType.prototype.onGlobalMouseDown = function(e) {
    if (e.target.classList.contains("dynamic_edit")) {
      return true;
    }
    this.editorShowing = false;
    this.elEditor.hide();
    return true;
  };

  DataFormatterType.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    if (!this.elEditor) {
      this.elEditor = $("<input />", {
        type: "text",
        "class": "dynamic_edit form-control"
      });
      this.appendEditor();
    }
    this.elEditor.css({
      position: "absolute",
      "z-index": 5001,
      top: top,
      left: left,
      width: width,
      height: height
    });
    this.elEditor.val(currentValue);
    this.elEditor.show();
    this.elEditor.focus();
    this.elEditor.select();
    return globalKeyboardEvents.once("global_mouse_down", this.onGlobalMouseDown);
  };

  DataFormatterType.prototype.onFocus = null;

  DataFormatterType.prototype.renderTooltip = function(row, value, tooltipWindow) {
    var h, w;
    if (value == null) {
      return false;
    }
    if (typeof value === "string" || typeof value === "number") {
      h = 60;
      w = 320;
      if (value.length > 100) {
        w = 440;
      }
      if (value.length > 200) {
        w = 640;
      }
      if (value.length > 300) {
        h = 440;
      }
      tooltipWindow.setSize(w, h);
      tooltipWindow.getBodyWidget().addClass("text");
      tooltipWindow.html(value);
      return true;
    }
    console.log("renderTooltip row=", row, "value=", value);
    return false;
  };

  return DataFormatterType;

})();

DataFormatText = (function(superClass) {
  extend(DataFormatText, superClass);

  function DataFormatText() {
    this.unformat = bind(this.unformat, this);
    this.renderTooltip = bind(this.renderTooltip, this);
    this.format = bind(this.format, this);
    return DataFormatText.__super__.constructor.apply(this, arguments);
  }

  DataFormatText.prototype.name = "text";

  DataFormatText.prototype.align = "left";

  DataFormatText.prototype.format = function(data, options, path) {
    var list, value, varName;
    if (data == null) {
      return "";
    }
    if (typeof data === "object") {
      if (Array.isArray(data)) {
        data = data.filter(function(a) {
          return a != null;
        }).join(", ");
      } else {
        list = [];
        for (varName in data) {
          value = data[varName];
          if (value == null) {
            continue;
          }
          list.push(varName + "=" + value);
        }
        data = list.join(", ");
      }
    }
    if (data.length > 300) {
      return data.slice(0, 301) + "...";
    }
    return data;
  };

  DataFormatText.prototype.renderTooltip = function(row, value, tooltipWindow) {
    var h, w;
    if (value == null) {
      return false;
    }
    if (typeof value === "string") {
      h = 60;
      w = 320;
      if (value.length > 100) {
        w = 440;
      }
      if (value.length > 200) {
        w = 640;
      }
      if (value.length > 300) {
        h = 440;
      }
      tooltipWindow.setSize(w, h);
      tooltipWindow.getBodyWidget().addClass("text");
      tooltipWindow.html(value);
      return true;
    }
    console.log("renderTooltip row=", row, "value=", value);
    return false;
  };

  DataFormatText.prototype.unformat = function(data, path) {
    return data;
  };

  return DataFormatText;

})(DataFormatterType);

DataFormatMemo = (function(superClass) {
  extend(DataFormatMemo, superClass);

  function DataFormatMemo() {
    this.openEditor = bind(this.openEditor, this);
    this.onFocus = bind(this.onFocus, this);
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatMemo.__super__.constructor.apply(this, arguments);
  }

  DataFormatMemo.prototype.name = "memo";

  DataFormatMemo.prototype.align = "left";

  DataFormatMemo.prototype.format = function(data, options, path) {
    if (data == null) {
      return "";
    }
    if (data.length === 0) {
      return "";
    }
    return "<span class='memo'>" + data.slice(0, 201) + "</span><span class='fieldicon'><i class='si si-eyeglasses'></i></span>";
  };

  DataFormatMemo.prototype.unformat = function(data, path) {
    return data;
  };

  DataFormatMemo.prototype.onFocus = function(e, col, data) {
    var content, m, text;
    console.log("e=", e);
    console.log("col=", col);
    console.log("data=", data);
    text = data[col];
    if ((text != null) && typeof text === "string" && text.length > 0) {
      content = "<br><textarea style='width:100%; height: 600px; font-size: 16px; line-height: 20px; font-family: Consolas, monospaced, arial;'>" + text + "</textarea>";
      m = new ModalDialog({
        showOnCreate: true,
        content: content,
        title: "View Contents",
        ok: "Done",
        close: ""
      });
    }
    return true;
  };

  DataFormatMemo.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    var code, codeEditor, codeMode, cx, cy, h, navButtonCancel, navButtonSave, popup, tag, w;
    cx = left + (width / 2);
    cy = top - 10;
    w = $(window).width();
    h = $(window).height();
    if (w > 1000) {
      w = 1000;
    } else if (w > 800) {
      w = 800;
    } else {
      w = 600;
    }
    if (h > 1000) {
      h = 1000;
    } else if (h > 800) {
      h = 800;
    } else if (h > 600) {
      h = 600;
    } else {
      h = 400;
    }
    popup = new PopupWindow("Text Editor");
    popup.resize(w, h);
    popup.centerToPoint(cx, cy - (popup.popupHeight / 2));
    navButtonSave = new NavButton("Save", "toolbar-btn navbar-btn btn-primary");
    navButtonSave.onClick = (function(_this) {
      return function(e) {
        _this.saveValue(codeEditor.getContent());
        return popup.destroy();
      };
    })(this);
    navButtonCancel = new NavButton("Cancel", "toolbar-btn navbar-btn btn-danger cancel-btn");
    navButtonCancel.onClick = (function(_this) {
      return function(e) {
        return popup.destroy();
      };
    })(this);
    popup.addToolbar([navButtonSave, navButtonCancel]);
    tag = $("<div />", {
      id: "editor_" + GlobalValueManager.NextGlobalID(),
      height: popup.windowWrapper.height()
    });
    popup.on("resize", (function(_this) {
      return function(ww, hh) {
        return tag.css("height", popup.windowWrapper.height());
      };
    })(this));
    popup.windowScroll.append(tag);
    codeMode = "markdown";
    if (typeof this.options === "string") {
      codeMode = this.options;
    }
    codeEditor = new CodeEditor(tag);
    if (!currentValue) {
      code = '';
    } else if (typeof currentValue !== 'string') {
      code = currentValue.toString();
    } else {
      code = currentValue;
    }
    codeEditor.setContent(code);
    popup.update();
    return true;
  };

  return DataFormatMemo;

})(DataFormatterType);

DataFormatSourceCode = (function(superClass) {
  extend(DataFormatSourceCode, superClass);

  function DataFormatSourceCode() {
    this.openEditor = bind(this.openEditor, this);
    return DataFormatSourceCode.__super__.constructor.apply(this, arguments);
  }

  DataFormatSourceCode.prototype.name = "sourcecode";

  DataFormatSourceCode.prototype.align = "left";

  DataFormatSourceCode.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    var code, codeEditor, codeMode, h, navButtonCancel, navButtonSave, popup, tag, w;
    w = $(window).width();
    h = $(window).height();
    width = 800;
    height = 600;
    if (width > w) {
      width = w - 10;
    }
    if (height > h) {
      height = h - 10;
    }
    top = (h - height) / 2;
    left = (w - width) / 2;
    popup = new PopupWindow("Source Code");
    popup.resize(w, h);
    navButtonSave = new NavButton("Save", "toolbar-btn navbar-btn btn-primary");
    navButtonSave.onClick = (function(_this) {
      return function(e) {
        _this.saveValue(codeEditor.getContent());
        return popup.destroy();
      };
    })(this);
    navButtonCancel = new NavButton("Cancel", "toolbar-btn navbar-btn btn-danger cancel-btn");
    navButtonCancel.onClick = (function(_this) {
      return function(e) {
        return popup.destroy();
      };
    })(this);
    popup.addToolbar([navButtonSave, navButtonCancel]);
    tag = $("<div />", {
      id: "editor_" + GlobalValueManager.NextGlobalID(),
      height: popup.windowWrapper.height()
    });
    popup.windowScroll.append(tag);
    codeMode = "javascript";
    if (typeof this.options === "string") {
      codeMode = this.options;
    }
    codeEditor = new CodeEditor(tag);
    codeEditor.popupMode().setTheme("tomorrow_night_eighties").setMode(codeMode);
    console.log("CURRENT=", currentValue);
    if (!currentValue) {
      code = '';
    } else if (typeof currentValue !== 'string') {
      code = currentValue.toString();
    } else {
      code = currentValue;
    }
    codeEditor.setContent(code);
    popup.update();
    return true;
  };

  return DataFormatSourceCode;

})(DataFormatText);

DataFormatInt = (function(superClass) {
  extend(DataFormatInt, superClass);

  function DataFormatInt() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatInt.__super__.constructor.apply(this, arguments);
  }

  DataFormatInt.prototype.name = "int";

  DataFormatInt.prototype.align = "right";

  DataFormatInt.prototype.width = 90;

  DataFormatInt.prototype.format = function(data, options, path) {
    if (data == null) {
      return "";
    }
    if (data === null || (typeof data === "string" && data.length === 0)) {
      return "";
    }
    if ((options != null) && options !== null) {
      return numeral(DataFormatter.getNumber(data)).format(options);
    }
    return numeral(DataFormatter.getNumber(data)).format("#,###");
  };

  DataFormatInt.prototype.unformat = function(data, path) {
    var num;
    num = DataFormatter.getNumber(data);
    if (isNaN(num)) {
      return "";
    }
    return Math.round(num);
  };

  return DataFormatInt;

})(DataFormatterType);

DataFormatNumber = (function(superClass) {
  extend(DataFormatNumber, superClass);

  function DataFormatNumber() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatNumber.__super__.constructor.apply(this, arguments);
  }

  DataFormatNumber.prototype.name = "number";

  DataFormatNumber.prototype.align = "right";

  DataFormatNumber.prototype.format = function(data, options, path) {
    var e, num;
    if (data == null) {
      return "";
    }
    num = DataFormatter.getNumber(data);
    if (data === null || (typeof data === "string" && data.length === 0)) {
      return "";
    }
    if (isNaN(num)) {
      return "[" + num + "]";
    }
    if ((options == null) || options === "") {
      options = "#,###.[##]";
    }
    try {
      return numeral(num).format(options);
    } catch (error) {
      e = error;
      console.log("Exception formatting number [" + num + "] using [" + optinos + "]");
      return retunr("[" + num + "]");
    }
  };

  DataFormatNumber.prototype.unformat = function(data, path) {
    console.log("unformat number:", data);
    return DataFormatter.getNumber(data);
  };

  return DataFormatNumber;

})(DataFormatterType);

DataFormatFloat = (function(superClass) {
  extend(DataFormatFloat, superClass);

  function DataFormatFloat() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.allowKey = bind(this.allowKey, this);
    return DataFormatFloat.__super__.constructor.apply(this, arguments);
  }

  DataFormatFloat.prototype.name = "decimal";

  DataFormatFloat.prototype.align = "right";

  DataFormatFloat.prototype.width = 100;

  DataFormatFloat.prototype.allowKey = function(keyCode) {
    return true;
    if (keyCode >= 48 && keyCode <= 57) {
      return true;
    }
    if (keyCode >= 96 && keyCode <= 105) {
      return true;
    }
    if (keyCode === 190) {
      return true;
    }
    if (keyCode === 189) {
      return true;
    }
    if (keyCode === 119) {
      return true;
    }
    if (keyCode === 109) {
      return true;
    }
    console.log("Rejecting key:", keyCode);
    return false;
  };

  DataFormatFloat.prototype.format = function(data, options, path) {
    if (data == null) {
      return "";
    }
    if ((options != null) && /#/.test(options)) {
      return numeral(DataFormatter.getNumber(data)).format(options);
    } else {
      return numeral(DataFormatter.getNumber(data)).format("#,###.##");
    }
  };

  DataFormatFloat.prototype.unformat = function(data, path) {
    return DataFormatter.getNumber(data);
  };

  return DataFormatFloat;

})(DataFormatterType);

DataFormatCurrency = (function(superClass) {
  extend(DataFormatCurrency, superClass);

  function DataFormatCurrency() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatCurrency.__super__.constructor.apply(this, arguments);
  }

  DataFormatCurrency.prototype.name = "money";

  DataFormatCurrency.prototype.align = "right";

  DataFormatCurrency.prototype.format = function(data, options, path) {
    if ((data == null) || data === null || data === 0 || data === "") {
      return "";
    }
    return numeral(DataFormatter.getNumber(data)).format('$ #,###.[##]');
  };

  DataFormatCurrency.prototype.unformat = function(data, path) {
    return DataFormatter.getNumber(data);
  };

  return DataFormatCurrency;

})(DataFormatterType);

DataFormatPercent = (function(superClass) {
  extend(DataFormatPercent, superClass);

  function DataFormatPercent() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatPercent.__super__.constructor.apply(this, arguments);
  }

  DataFormatPercent.prototype.name = "percent";

  DataFormatPercent.prototype.align = "right";

  DataFormatPercent.prototype.format = function(data, options, path) {
    return numeral(DataFormatter.getNumber(data)).format('#,###.[##] %');
  };

  DataFormatPercent.prototype.unformat = function(data, path) {
    var num;
    num = DataFormatter.getNumber(data);
    return num;
  };

  return DataFormatPercent;

})(DataFormatterType);

DataFormatDate = (function(superClass) {
  extend(DataFormatDate, superClass);

  function DataFormatDate() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatDate.__super__.constructor.apply(this, arguments);
  }

  DataFormatDate.prototype.name = "date";

  DataFormatDate.prototype.width = 65;

  DataFormatDate.prototype.align = "left";

  DataFormatDate.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    if (!this.elEditor) {
      this.elEditor = $("<input />", {
        type: "text",
        "class": "dynamic_edit"
      });
      this.appendEditor();
      this.elEditor.on('keydown', (function(_this) {
        return function(e) {
          if (!_this.editorShowing) {
            return _this.datePicker.close();
          }
        };
      })(this));
    }
    this.datePicker = new flatpickr(this.elEditor[0], {
      allowInput: true,
      parseDate: function(dateString) {
        return DataFormatter.getMoment(dateString);
      },
      onChange: (function(_this) {
        return function(dateObject, dateString) {
          _this.saveValue(dateObject);
          _this.editorShowing = false;
          return _this.elEditor.hide();
        };
      })(this),
      onOpen: (function(_this) {
        return function(dateObj, dateStr, instance) {
          return instance.setDate(new Date(currentValue));
        };
      })(this)
    });
    this.elEditor.css({
      position: "absolute",
      "z-index": 5001,
      top: top,
      left: left,
      width: width,
      height: height
    });
    this.elEditor.val(currentValue);
    this.elEditor.show();
    return this.elEditor.focus();
  };

  DataFormatDate.prototype.format = function(data, options, path) {
    var m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "";
    }
    return m.format("MM/DD/YYYY");
  };

  DataFormatDate.prototype.unformat = function(data, path) {
    var m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "";
    }
    return m.format("YYYY-MM-DD HH:mm:ss");
  };

  return DataFormatDate;

})(DataFormatterType);

DataFormatTags = (function(superClass) {
  extend(DataFormatTags, superClass);

  function DataFormatTags() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatTags.__super__.constructor.apply(this, arguments);
  }

  DataFormatTags.prototype.name = "tags";

  DataFormatTags.prototype.align = "left";

  DataFormatTags.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    var m;
    m = new ModalDialog({
      showOnCreate: false,
      content: "Enter the list of items",
      title: "Edit options",
      ok: "Save"
    });
    if (typeof currentValue === "string") {
      currentValue = currentValue.split(',');
    }
    m.getForm().addTagsInput("input1", "Value", currentValue.join(','));
    m.getForm().onSubmit = (function(_this) {
      return function(form) {
        _this.saveValue(form.input1.split(","));
        return m.hide();
      };
    })(this);
    return m.show();
  };

  DataFormatTags.prototype.format = function(currentValue, options, path) {
    var idx, obj, values;
    if (typeof currentValue === "string") {
      currentValue = currentValue.split(',');
    }
    if (Array.isArray(currentValue)) {
      return currentValue.sort().join(", ");
    }
    values = [];
    for (idx in currentValue) {
      obj = currentValue[idx];
      values.push(obj);
    }
    return values.sort().join(", ");
  };

  DataFormatTags.prototype.unformat = function(currentValue, path) {
    if (typeof currentValue === "string") {
      currentValue = currentValue.split(',');
    }
    return currentValue;
  };

  return DataFormatTags;

})(DataFormatterType);

DataFormatMultiselect = (function(superClass) {
  extend(DataFormatMultiselect, superClass);

  function DataFormatMultiselect() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatMultiselect.__super__.constructor.apply(this, arguments);
  }

  DataFormatMultiselect.prototype.name = "multiselect";

  DataFormatMultiselect.prototype.options = [];

  DataFormatMultiselect.prototype.align = "left";

  DataFormatMultiselect.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    var m;
    m = new ModalDialog({
      showOnCreate: false,
      content: "Select the list of items",
      title: "Select options",
      ok: "Save"
    });
    if (typeof currentValue === "string") {
      currentValue = currentValue.split(',');
    }
    m.getForm().addMultiselect("select1", "Selection", currentValue.join(','), {
      options: this.options
    });
    m.getForm().onSubmit = (function(_this) {
      return function(form) {
        _this.saveValue(form.select1);
        return m.hide();
      };
    })(this);
    return m.show();
  };

  DataFormatMultiselect.prototype.format = function(currentValue, options, path) {
    var idx, obj, values;
    this.options = options;
    if (typeof currentValue === "string") {
      currentValue = currentValue.split(',');
    }
    if (Array.isArray(currentValue)) {
      return currentValue.join(", ");
    }
    values = [];
    for (idx in currentValue) {
      obj = currentValue[idx];
      values.push(obj);
    }
    return values.join(", ");
  };

  DataFormatMultiselect.prototype.unformat = function(currentValue, path) {
    if (typeof currentValue === "string") {
      currentValue = currentValue.split(',');
    }
    return currentValue;
  };

  return DataFormatMultiselect;

})(DataFormatterType);

DataFormatDateTime = (function(superClass) {
  extend(DataFormatDateTime, superClass);

  function DataFormatDateTime() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatDateTime.__super__.constructor.apply(this, arguments);
  }

  DataFormatDateTime.prototype.name = "datetime";

  DataFormatDateTime.prototype.align = "left";

  DataFormatDateTime.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    if (!this.elEditor) {
      this.elEditor = $("<input />", {
        type: "text",
        "class": "dynamic_edit"
      });
      this.appendEditor();
      this.elEditor.on('keydown', (function(_this) {
        return function(e) {
          if (!_this.editorShowing) {
            return _this.datePicker.close();
          }
        };
      })(this));
    }
    this.datePicker = new flatpickr(this.elEditor[0], {
      allowInput: true,
      parseDate: function(dateString) {
        return DataFormatter.getMoment(dateString);
      },
      onChange: (function(_this) {
        return function(dateObject, dateString) {
          _this.saveValue(dateObject);
          _this.editorShowing = false;
          return _this.elEditor.hide();
        };
      })(this),
      onOpen: (function(_this) {
        return function(dateObj, dateStr, instance) {
          instance.setDate(new Date(currentValue));
          return instance.setTime(DataFormatter.getMoment(new Date(currentValue)).format('HH:mm:ss'));
        };
      })(this),
      enableTime: true,
      time_24hr: true
    });
    this.elEditor.css({
      position: "absolute",
      "z-index": 5001,
      top: top,
      left: left,
      width: width,
      height: height
    });
    this.elEditor.val(currentValue);
    this.elEditor.show();
    return this.elEditor.focus();
  };

  DataFormatDateTime.prototype.format = function(data, options, path) {
    var m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "";
    }
    return m.format("ddd, MMM Do, YYYY h:mm:ss a");
  };

  DataFormatDateTime.prototype.unformat = function(data, path) {
    var m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "";
    }
    return m.format("YYYY-MM-DD HH:mm:ss");
  };

  return DataFormatDateTime;

})(DataFormatterType);

DataFormatDateAge = (function(superClass) {
  extend(DataFormatDateAge, superClass);

  function DataFormatDateAge() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatDateAge.__super__.constructor.apply(this, arguments);
  }

  DataFormatDateAge.prototype.name = "age";

  DataFormatDateAge.prototype.width = 135;

  DataFormatDateAge.prototype.align = "left";

  DataFormatDateAge.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    if (!this.elEditor) {
      this.elEditor = $("<input />", {
        type: "text",
        "class": "dynamic_edit"
      });
      this.appendEditor();
      this.elEditor.on('keydown', (function(_this) {
        return function(e) {
          if (!_this.editorShowing) {
            return _this.datePicker.close();
          }
        };
      })(this));
    }
    this.datePicker = new flatpickr(this.elEditor[0], {
      allowInput: true,
      parseDate: function(dateString) {
        return DataFormatter.getMoment(dateString);
      },
      onChange: (function(_this) {
        return function(dateObject, dateString) {
          _this.saveValue(dateObject);
          _this.editorShowing = false;
          return _this.elEditor.hide();
        };
      })(this),
      onOpen: (function(_this) {
        return function(dateObj, dateStr, instance) {
          instance.setDate(new Date(currentValue));
          return instance.setTime(DataFormatter.getMoment(new Date(currentValue)).format('HH:mm:ss'));
        };
      })(this),
      enableTime: true,
      time_24hr: true
    });
    this.elEditor.css({
      position: "absolute",
      "z-index": 5001,
      top: top,
      left: left,
      width: width,
      height: height
    });
    this.elEditor.val(currentValue);
    this.elEditor.show();
    return this.elEditor.focus();
  };

  DataFormatDateAge.prototype.format = function(data, options, path) {
    var age, html, m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "";
    }
    html = "<span class='fdate'>" + m.format("MM/DD/YYYY") + "</span>";
    age = moment().diff(m);
    age = age / 86400000;
    if (age < 401) {
      age = numeral(age).format("#") + " d";
    } else if (age < 365 * 2) {
      age = numeral(age / 30.5).format("#") + " mn";
    } else {
      age = numeral(age / 365).format("#.#") + " yrs";
    }
    html += "<span class='fage'>" + age + "</span>";
    return html;
  };

  DataFormatDateAge.prototype.unformat = function(data, path) {
    var m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "";
    }
    return m.format("YYYY-MM-DD HH:mm:ss");
  };

  return DataFormatDateAge;

})(DataFormatterType);

DataFormatEnum = (function(superClass) {
  extend(DataFormatEnum, superClass);

  function DataFormatEnum() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatEnum.__super__.constructor.apply(this, arguments);
  }

  DataFormatEnum.prototype.name = "enum";

  DataFormatEnum.prototype.align = "left";

  DataFormatEnum.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    var i, o, p, ref;
    p = new PopupMenu("Options", left, top);
    if (typeof this.options === "string") {
      this.options = this.options.split(",");
    }
    if (typeof this.options === "object" && typeof this.options.length === "number") {
      ref = this.options;
      for (i in ref) {
        o = ref[i];
        p.addItem(o, (function(_this) {
          return function(coords, data) {
            return _this.saveValue(data);
          };
        })(this), o);
      }
    } else {
      console.log("Invalid options: ", this.options);
    }
    return true;
  };

  DataFormatEnum.prototype.format = function(data, options1, path) {
    var i, o, ref, ref1;
    this.options = options1;
    if (typeof this.options === "string") {
      this.options = this.options.split(/\s*,\s*/);
    }
    if (data == null) {
      return "";
    }
    ref = this.options;
    for (i in ref) {
      o = ref[i];
      if (data === o) {
        return o;
      }
    }
    ref1 = this.options;
    for (i in ref1) {
      o = ref1[i];
      if (("" + data) === ("" + i)) {
        return o;
      }
    }
    return "[" + data + "]";
  };

  DataFormatEnum.prototype.unformat = function(data, path) {
    return data;
  };

  return DataFormatEnum;

})(DataFormatterType);

DataFormatDistance = (function(superClass) {
  extend(DataFormatDistance, superClass);

  function DataFormatDistance() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatDistance.__super__.constructor.apply(this, arguments);
  }

  DataFormatDistance.prototype.name = "distance";

  DataFormatDistance.prototype.width = 100;

  DataFormatDistance.prototype.align = "left";

  DataFormatDistance.prototype.format = function(data, options, path) {
    var feet;
    if (data === 0) {
      return 0;
    }
    feet = 3.28084 * data;
    if (feet < 50) {
      return "< 50 ft";
    }
    if (feet < 1000) {
      return Math.ceil(feet) + " ft";
    }
    data = feet / 5280;
    return numeral(data).format('#,###.##') + " mi";
  };

  DataFormatDistance.prototype.unformat = function(data, path) {
    var val;
    console.log("Unformat distance doesn't work:", data);
    val = DataFormatter.getNumber(data);
    return val;
  };

  return DataFormatDistance;

})(DataFormatterType);

DataFormatBoolean = (function(superClass) {
  extend(DataFormatBoolean, superClass);

  function DataFormatBoolean() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatBoolean.__super__.constructor.apply(this, arguments);
  }

  DataFormatBoolean.prototype.name = "boolean";

  DataFormatBoolean.prototype.width = 40;

  DataFormatBoolean.prototype.textYes = "<i class='fa fa-circle'></i> Yes";

  DataFormatBoolean.prototype.textNo = "<i class='fa fa-circle-thin'></i> No";

  DataFormatBoolean.prototype.textNotSet = "<i class='fa fa-fs'></i> Not Set";

  DataFormatBoolean.prototype.align = "left";

  DataFormatBoolean.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    if (currentValue) {
      currentValue = false;
    } else {
      currentValue = true;
    }
    this.saveValue(currentValue);
    return true;
  };

  DataFormatBoolean.prototype.format = function(data, options, path) {
    if (data == null) {
      return this.textNotSet;
    }
    if (data === "") {
      return this.textNotSet;
    }
    if (data === null || data === 0 || data === false) {
      return this.textNo;
    }
    return this.textYes;
  };

  DataFormatBoolean.prototype.unformat = function(data, path) {
    if (data == null) {
      return false;
    }
    if (typeof data === "boolean") {
      if (data) {
        return true;
      }
      return false;
    }
    if (data === null || data === 0) {
      return false;
    }
    if (data === "No" || data === "no" || data === "false" || data === "off") {
      return false;
    }
    return true;
  };

  return DataFormatBoolean;

})(DataFormatterType);

DataFormatTimeAgo = (function(superClass) {
  extend(DataFormatTimeAgo, superClass);

  function DataFormatTimeAgo() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatTimeAgo.__super__.constructor.apply(this, arguments);
  }

  DataFormatTimeAgo.prototype.name = "timeago";

  DataFormatTimeAgo.prototype.width = 135;

  DataFormatTimeAgo.prototype.align = "left";

  DataFormatTimeAgo.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    if (!this.elEditor) {
      this.elEditor = $("<input />", {
        type: "text",
        "class": "dynamic_edit"
      });
      this.appendEditor();
      this.elEditor.on('keydown', (function(_this) {
        return function(e) {
          if (!_this.editorShowing) {
            return _this.datePicker.close();
          }
        };
      })(this));
    }
    this.datePicker = new flatpickr(this.elEditor[0], {
      allowInput: true,
      parseDate: function(dateString) {
        return DataFormatter.getMoment(dateString);
      },
      onChange: (function(_this) {
        return function(dateObject, dateString) {
          _this.saveValue(dateObject);
          _this.editorShowing = false;
          return _this.elEditor.hide();
        };
      })(this),
      onOpen: (function(_this) {
        return function(dateObj, dateStr, instance) {
          instance.setDate(new Date(currentValue));
          return instance.setTime(DataFormatter.getMoment(new Date(currentValue)).format('HH:mm:ss'));
        };
      })(this),
      enableTime: true,
      time_24hr: true
    });
    this.elEditor.css({
      position: "absolute",
      "z-index": 5001,
      top: top,
      left: left,
      width: width,
      height: height
    });
    this.elEditor.val(currentValue);
    this.elEditor.show();
    return this.elEditor.focus();
  };

  DataFormatTimeAgo.prototype.format = function(data, options, path) {
    var age, days, daysTxt, hrs, hrsText, min, stamp, txt;
    if (data == null) {
      return "";
    }
    if (typeof data === "string") {
      stamp = new Date(data);
    } else if (typeof data === "number") {
      stamp = new Date(data);
    } else if (typeof data === "object" && (data.getTime != null)) {
      stamp = data;
    } else {
      return "";
    }
    age = new Date().getTime() - stamp.getTime();
    age /= 1000;
    if (age < 60) {
      txt = numeral(age).format("#") + " sec";
    } else if (age < (60 * 60)) {
      txt = numeral(age / 60).format("#") + " min";
    } else if (age > 86400) {
      days = Math.floor(age / 86400);
      hrs = Math.floor((age - (days * 86400)) / (60 * 60));
      if (days !== 1) {
        daysTxt = "days";
      } else {
        daysTxt = "day";
      }
      if (hrs > 0 && days < 30) {
        txt = days + " " + daysTxt + ", " + hrs + " hr";
        if (hrs !== 1) {
          txt += "s";
        }
      } else {
        txt = days + " " + daysTxt;
      }
    } else {
      hrs = Math.floor(age / (60 * 60));
      min = (age - (hrs * 60 * 60)) / 60;
      if (hrs > 1) {
        hrsText = "hrs";
      } else {
        hrsText = "hr";
      }
      txt = numeral(hrs).format("#") + (" " + hrsText + ", ") + numeral(min).format("#") + " min";
    }
    return txt;
  };

  DataFormatTimeAgo.prototype.unformat = function(data, path) {
    var m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "";
    }
    return m.format("YYYY-MM-DD HH:mm:ss");
  };

  return DataFormatTimeAgo;

})(DataFormatterType);

DataFormatDuration = (function(superClass) {
  extend(DataFormatDuration, superClass);

  function DataFormatDuration() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatDuration.__super__.constructor.apply(this, arguments);
  }

  DataFormatDuration.prototype.name = "duration";

  DataFormatDuration.prototype.width = 90;

  DataFormatDuration.prototype.align = "right";

  DataFormatDuration.prototype.format = function(data, options, path) {
    var hrs, min, sec, txt;
    if (data == null) {
      return "";
    }
    if (typeof data === "string") {
      data = parseFloat(options);
    }
    sec = data / 1000;
    if (sec < 60) {
      txt = numeral(sec).format("#.###") + " sec";
    } else if (sec < (60 * 60 * 2)) {
      min = Math.floor(sec / 60);
      sec = sec - (min * 60);
      txt = min + " min, " + Math.floor(sec) + " sec.";
    } else {
      hrs = Math.floor(sec / (60 * 60));
      min = Math.floor(sec - (hrs * 60 * 60));
      txt = hrs + " hrs, " + min + " min";
    }
    return txt;
  };

  DataFormatDuration.prototype.unformat = function(data, path) {
    return data;
  };

  return DataFormatDuration;

})(DataFormatterType);

DataFormatSimpleObject = (function(superClass) {
  extend(DataFormatSimpleObject, superClass);

  function DataFormatSimpleObject() {
    this.unformat = bind(this.unformat, this);
    this.onFocus = bind(this.onFocus, this);
    this.renderTooltip = bind(this.renderTooltip, this);
    this.format = bind(this.format, this);
    return DataFormatSimpleObject.__super__.constructor.apply(this, arguments);
  }

  DataFormatSimpleObject.prototype.name = "simpleobject";

  DataFormatSimpleObject.prototype.align = "left";

  DataFormatSimpleObject.prototype.format = function(data, options, path) {
    if (data == null) {
      return "Not set";
    }
    if ((data != null) && Array.isArray(data)) {
      if (data.length === 0) {
        return "Not set";
      }
      if (typeof data[0] === "string") {
        return data.sort().filter(function(a) {
          return a != null;
        }).join(", ");
      }
    }
    return "View";
  };

  DataFormatSimpleObject.prototype.renderTooltip = function(row, value, tooltipWindow) {
    var height, str, val, varName;
    if (value == null) {
      return false;
    }
    height = 20;
    str = "<table>";
    for (varName in value) {
      val = value[varName];
      str += "<tr><td>";
      str += varName;
      str += "</td><td>";
      str += val;
      str += "</tr>";
      height += 20;
    }
    str += "</table>";
    tooltipWindow.html(str);
    tooltipWindow.setSize(400, height);
    return true;
  };

  DataFormatSimpleObject.prototype.onFocus = function(e, col, data) {
    console.log("e=", e);
    console.log("col=", col);
    return console.log("data=", data);
  };

  DataFormatSimpleObject.prototype.unformat = function(data, path) {
    console.log("unformat simple:", data);
    return data;
  };

  return DataFormatSimpleObject;

})(DataFormatterType);

DataFormatLink = (function(superClass) {
  extend(DataFormatLink, superClass);

  function DataFormatLink() {
    this.onFocus = bind(this.onFocus, this);
    this.openEditor = bind(this.openEditor, this);
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatLink.__super__.constructor.apply(this, arguments);
  }

  DataFormatLink.prototype.name = "link";

  DataFormatLink.prototype.width = 70;

  DataFormatLink.prototype.clickable = true;

  DataFormatLink.prototype.align = "left";

  DataFormatLink.prototype.format = function(data, options, path) {
    if (data == null) {
      return "";
    }
    if (/www/.test(data)) {
      return "Open Link";
    }
    if (/^http/.test(data)) {
      return "Open Link";
    }
    if (/^ftp/.test(data)) {
      return "Open FTP";
    }
    if (data.length > 0) {
      return data;
    }
    return "";
  };

  DataFormatLink.prototype.unformat = function(data, path) {
    console.log("TODO: DataFormatLink.unformat not implemented:", data);
    return data;
  };

  DataFormatLink.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    console.log("TODO: openEditor not implemented for link");
    return null;
  };

  DataFormatLink.prototype.onFocus = function(e, col, data) {
    var url, win;
    console.log("click, col=", col, "data=", data);
    url = data[col];
    if ((url != null) && url.length > 0) {
      win = window.open(url, "_blank");
      win.focus();
    }
    return true;
  };

  return DataFormatLink;

})(DataFormatterType);

DataFormatImageList = (function(superClass) {
  extend(DataFormatImageList, superClass);

  function DataFormatImageList() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatImageList.__super__.constructor.apply(this, arguments);
  }

  DataFormatImageList.prototype.name = "imagelist";

  DataFormatImageList.prototype.options = [];

  DataFormatImageList.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    var h, imgCount, title, w;
    if (currentValue == null) {
      return false;
    }
    w = $(window).width();
    h = $(window).height();
    if (w > 1000) {
      w = 1000;
    } else if (w > 800) {
      w = 800;
    } else {
      w = 600;
    }
    if (h > 1000) {
      h = 1000;
    } else if (h > 800) {
      h = 800;
    } else if (h > 600) {
      h = 600;
    } else {
      h = 400;
    }
    if (typeof currentValue === "string") {
      currentValue = currentValue.split("||");
    }
    imgCount = currentValue.length;
    if (imgCount < 1) {
      return false;
    } else if (imgCount === 1) {
      title = "View Image";
    } else {
      title = "View " + imgCount + " Images";
    }
    return doPopupView('ImageStrip', title, 'imagestrip_popup', w, h).then(function(view) {
      var img, j, len;
      view.init();
      for (j = 0, len = currentValue.length; j < len; j++) {
        img = currentValue[j];
        view.addImage(img);
      }
      return view.render();
    });
  };

  DataFormatImageList.prototype.format = function(currentValue, options, path) {
    var formattedValue, imgCount;
    this.options = options;

    /*
    		if typeof currentValue == "string"
    			currentValue = currentValue.split ','
    
    		if Array.isArray(currentValue)
    			return currentValue.join(", ")
    
    		values = []
    		for idx, obj of currentValue
    			values.push obj
    		return values.join(", ")
     */
    formattedValue = "No Image";
    if (typeof currentValue === "string") {
      currentValue = currentValue.split("||");
    } else if (currentValue == null) {
      return formattedValue;
    }
    imgCount = currentValue.length;
    console.log(imgCount);
    if (imgCount === 1) {
      formattedValue = "1 Image";
    } else {
      formattedValue = imgCount + " Images";
    }
    return formattedValue;
  };

  DataFormatImageList.prototype.unformat = function(currentValue, path) {
    if (typeof currentValue === "string") {
      currentValue = currentValue.split(',');
    }
    return currentValue;
  };

  return DataFormatImageList;

})(DataFormatterType);

try {
  globalDataFormatter = new DataFormatter();
  globalDataFormatter.register(new DataFormatText());
  globalDataFormatter.register(new DataFormatInt());
  globalDataFormatter.register(new DataFormatNumber());
  globalDataFormatter.register(new DataFormatFloat());
  globalDataFormatter.register(new DataFormatCurrency());
  globalDataFormatter.register(new DataFormatDate());
  globalDataFormatter.register(new DataFormatDateTime());
  globalDataFormatter.register(new DataFormatDateAge());
  globalDataFormatter.register(new DataFormatEnum());
  globalDataFormatter.register(new DataFormatDistance());
  globalDataFormatter.register(new DataFormatBoolean());
  globalDataFormatter.register(new DataFormatPercent());
  globalDataFormatter.register(new DataFormatTimeAgo());
  globalDataFormatter.register(new DataFormatSimpleObject());
  globalDataFormatter.register(new DataFormatSourceCode());
  globalDataFormatter.register(new DataFormatTags());
  globalDataFormatter.register(new DataFormatMultiselect());
  globalDataFormatter.register(new DataFormatMemo());
  globalDataFormatter.register(new DataFormatDuration());
  globalDataFormatter.register(new DataFormatLink());
  globalDataFormatter.register(new DataFormatImageList());
} catch (error) {
  e = error;
  console.log("Exception while registering global Data Formatter:", e);
}
var ModalMessageBox,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ModalMessageBox = (function(superClass) {
  extend(ModalMessageBox, superClass);

  ModalMessageBox.prototype.content = "Default content";

  ModalMessageBox.prototype.title = "Default title";

  ModalMessageBox.prototype.ok = "Ok";

  ModalMessageBox.prototype.close = "Close";

  ModalMessageBox.prototype.showFooter = true;

  ModalMessageBox.prototype.showOnCreate = true;

  function ModalMessageBox(message) {
    this.showOnCreate = false;
    ModalMessageBox.__super__.constructor.call(this);
    this.title = "Information";
    this.position = 'center';
    this.ok = 'Close';
    this.close = '';
    this.content = message;
    this.show();
  }

  return ModalMessageBox;

})(ModalDialog);
var ModalViewDialog,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ModalViewDialog = (function(superClass) {
  extend(ModalViewDialog, superClass);

  function ModalViewDialog(options) {
    this.show = bind(this.show, this);
    ModalViewDialog.__super__.constructor.call(this, options);
    this.view = new View();
  }

  ModalViewDialog.prototype.show = function(options) {
    this.content += "<div class='modal_ViewDialog' id='modal_ViewDialog" + this.gid + "' />";
    this.html = this.template(this);
    $("body").append(this.html);
    this.view.AddToElement("#modal_ViewDialog" + this.gid);
    this.view.elHolder.append(this.getForm().getHtml());
    this.modal = $("#modal" + this.gid);
    this.modal.modal(options);
    this.modal.on("hidden.bs.modal", (function(_this) {
      return function() {
        _this.modal.remove();
        return _this.onClose();
      };
    })(this));
    this.modal.find(".btn1").bind("click", (function(_this) {
      return function() {
        return _this.onButton1();
      };
    })(this));
    this.modal.find(".btn2").bind("click", (function(_this) {
      return function(e) {
        e.preventDefault();
        e.stopPropagation();
        options = {};
        _this.modal.find("input,select").each(function(idx, el) {
          var name, val;
          name = $(el).attr("name");
          val = $(el).val();
          return options[name] = val;
        });
        if (_this.onButton2(e, options) === true) {
          _this.onClose();
        }
        return true;
      };
    })(this));
    if (this.position === "center") {
      this.modal.css({
        'margin-top': (function(_this) {
          return function() {
            return Math.max(0, $(window).scrollTop() + ($(window).height() - _this.modal.height()) / 2);
          };
        })(this)
      });
    }
    if (this.formWrapper != null) {
      return setTimeout((function(_this) {
        return function() {
          return _this.formWrapper.onAfterShow();
        };
      })(this), 10);
    }
  };

  return ModalViewDialog;

})(ModalDialog);
var FloatingSelect,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

FloatingSelect = (function(superClass) {
  extend(FloatingSelect, superClass);

  function FloatingSelect() {
    this.showTable = bind(this.showTable, this);
    this.setTable = bind(this.setTable, this);
    this.onResize = bind(this.onResize, this);
    this.show = bind(this.show, this);
    this.hide = bind(this.hide, this);
    this.destroy = bind(this.destroy, this);
    this.getOptionHeight = bind(this.getOptionHeight, this);
    return FloatingSelect.__super__.constructor.apply(this, arguments);
  }

  FloatingSelect.prototype.table = null;

  FloatingSelect.prototype.optionHeight = 24;

  FloatingSelect.prototype.getOptionHeight = function() {
    return this.optionHeight;
  };

  FloatingSelect.prototype.destroy = function() {
    if (this.table != null) {
      this.table.destroy();
    }
    delete this.table;
    FloatingSelect.__super__.destroy.call(this);
    return true;
  };

  FloatingSelect.prototype.hide = function() {
    if (this.table != null) {
      this.table.hide();
    }
    FloatingSelect.__super__.hide.call(this);
    return true;
  };

  FloatingSelect.prototype.show = function() {
    FloatingSelect.__super__.show.apply(this, arguments).show();
    this.showTable();
    setTimeout(this.table.onResize, 10);
    return true;
  };

  FloatingSelect.prototype.onResize = function() {
    if (this.table != null) {
      this.table.onResize();
    }
    return true;
  };

  FloatingSelect.prototype.setTable = function(tableName, columns, config) {
    this.tableName = tableName;
    this.columns = columns;
    return GlobalClassTools.addEventManager(this);
  };

  FloatingSelect.prototype.showTable = function() {
    if (this.table != null) {
      return this.table;
    }
    this.table = new TableView(this.elHolder.el, false);
    this.table.showGroupPadding = false;
    this.table.showResize = false;
    this.table.setAutoFillWidth();
    this.table.addTable(this.tableName, (function(_this) {
      return function(colName) {
        var i, len, opt, ref;
        if (_this.columns == null) {
          return true;
        }
        ref = _this.columns;
        for (i = 0, len = ref.length; i < len; i++) {
          opt = ref[i];
          if (opt === colName.getSource()) {
            return true;
          }
        }
        return false;
      };
    })(this));
    this.table.on("click_row", (function(_this) {
      return function(row, e) {
        _this.emitEvent("select", [row]);
        return true;
      };
    })(this));
    this.table.on("focus_cell", (function(_this) {
      return function(path, item) {
        console.log("on focus cell:", path, item);
        _this.emitEvent("preselect", [item.id, item]);
        return true;
      };
    })(this));
    if ((typeof config !== "undefined" && config !== null) && config.showHeaders) {
      this.table.showHeaders = true;
    }
    this.table.setFixedSize(this.width, this.height);
    this.table.render();
    this.table.onResize();
    return true;
  };

  return FloatingSelect;

})(FloatingWindow);
var ModalSortItems,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ModalSortItems = (function(superClass) {
  extend(ModalSortItems, superClass);

  ModalSortItems.prototype.content = "Sort Columns";

  ModalSortItems.prototype.title = "Customize Columns";

  ModalSortItems.prototype.ok = "Close";

  ModalSortItems.prototype.close = "";

  ModalSortItems.prototype.showFooter = true;

  ModalSortItems.prototype.showOnCreate = false;

  ModalSortItems.prototype.imgChecked = "<img src='/images/checkbox.png' width='16' height='16' alt='Selected' />";

  ModalSortItems.prototype.imgNotChecked = "<img src='/images/checkbox_no.png' width='16' height='16' alt='Selected' />";

  ModalSortItems.prototype.updateColumnText = function() {
    var col, i, len, ref;
    ref = this.columns;
    for (i = 0, len = ref.length; i < len; i++) {
      col = ref[i];
      if (col.getAlwaysHidden()) {
        continue;
      }
      col.tagName.html(col.getName());
      col.tagOrderText.html(col.getOrder() + 1);
      if (col.getVisible()) {
        col.tagCheck.html(this.imgChecked);
        col.tag.removeClass("notVisible");
      } else {
        col.tagCheck.html(this.imgNotChecked);
        col.tag.addClass("notVisible");
      }
      col.tag.setClass("calculation", col.getIsCalculation());
    }
    return true;
  };

  ModalSortItems.prototype.onClickVisible = function(e) {
    var col, i, len, ref, results;
    ref = this.columns;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      col = ref[i];
      if (col.getAlwaysHidden()) {
        continue;
      }
      if (col.getSource() !== e.path) {
        continue;
      }
      DataMap.changeColumnAttribute(this.tableName, e.path, "visible", col.getVisible() === false);
      results.push(this.updateColumnText());
    }
    return results;
  };

  function ModalSortItems(tableName) {
    var col, i, len, ref;
    this.tableName = tableName;
    this.onClickVisible = bind(this.onClickVisible, this);
    this.updateColumnText = bind(this.updateColumnText, this);
    ModalSortItems.__super__.constructor.call(this);
    GlobalClassTools.addEventManager(this);
    this.content = '<div id=\'tableColumnSortingList\' class=\'tableColumnSortingList\'>\n</div>';
    this.show();
    this.sortItemsList = new WidgetTag("ul", "sortedItemsList", "sortedItemsList");
    $("#tableColumnSortingList").append(this.sortItemsList.el);
    this.columns = DataMap.getColumnsFromTable(this.tableName);
    this.columns = this.columns.sort(function(a, b) {
      return a.getOrder() - b.getOrder();
    });
    ref = this.columns;
    for (i = 0, len = ref.length; i < len; i++) {
      col = ref[i];
      if (col.getAlwaysHidden()) {
        continue;
      }
      col.tag = this.sortItemsList.add("li", "columnItem");
      col.gid = col.tag.gid;
      col.tagCheck = col.tag.add("div", "colVisible");
      col.tagName = col.tag.add("div", "colName");
      col.tagOrderText = col.tag.add("div", "orderText");
      col.tagCheck.setDataPath(col.getSource());
      col.tagCheck.on("click", this.onClickVisible);
    }
    this.updateColumnText();
    sortable("#sortedItemsList", {
      forcePlaceholderSize: true,
      placeholderClass: 'placeholder'
    });
    sortable('#sortedItemsList')[0].addEventListener('sortupdate', (function(_this) {
      return function(e) {
        var el, id, j, k, len1, len2, oldOrder, order, ref1, ref2;
        console.log("SORT UPDATE:", e.detail);
        order = 0;
        ref1 = _this.sortItemsList.el.children();
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          el = ref1[j];
          id = $(el).data("id");
          ref2 = _this.columns;
          for (k = 0, len2 = ref2.length; k < len2; k++) {
            col = ref2[k];
            if (col.getAlwaysHidden()) {
              continue;
            }
            if (col.gid !== id) {
              continue;
            }
            oldOrder = col.getOrder();
            if (oldOrder !== order) {
              DataMap.changeColumnAttribute(_this.tableName, col.getSource(), "order", order);
              console.log("Change " + (col.getSource()) + " order from " + oldOrder + " to " + order);
            }
            order++;
          }
        }
        _this.updateColumnText();
        return true;
      };
    })(this));
    this.onButton1 = (function(_this) {
      return function(e) {
        _this.hide();
        return true;
      };
    })(this);
    this.onButton2 = (function(_this) {
      return function() {
        _this.hide();
        return true;
      };
    })(this);
  }

  return ModalSortItems;

})(ModalDialog);
var ErrorMessageBox,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ErrorMessageBox = (function(superClass) {
  extend(ErrorMessageBox, superClass);

  ErrorMessageBox.prototype.content = "Default content";

  ErrorMessageBox.prototype.title = "Default title";

  ErrorMessageBox.prototype.ok = "Ok";

  ErrorMessageBox.prototype.close = "Close";

  ErrorMessageBox.prototype.showFooter = true;

  ErrorMessageBox.prototype.showOnCreate = true;

  function ErrorMessageBox(message) {
    this.showOnCreate = false;
    ErrorMessageBox.__super__.constructor.call(this);
    console.log("MESSAGE=", message);
    this.title = "Error";
    this.position = 'center';
    this.ok = 'Close';
    this.close = '';
    this.content = message;
    this.show();
  }

  return ErrorMessageBox;

})(ModalDialog);
var PopupForm,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

PopupForm = (function(superClass) {
  extend(PopupForm, superClass);

  PopupForm.prototype.showOnCreate = false;

  PopupForm.prototype.content = "";

  PopupForm.prototype.close = "Cancel";

  function PopupForm(tableName, keyElement, key, columns, defaults) {
    this.tableName = tableName;
    this.keyElement = keyElement;
    this.key = key;
    this.columns = columns;
    this.defaults = defaults;
    if (!this.keyElement) {
      throw new Error("Key name is not supplied in the PopupForm");
    }
    this.title = this.key ? 'Edit ' : 'Create ';
    this.ok = this.key ? 'Save Changes' : 'Create New';
    PopupForm.__super__.constructor.call(this);
    if (!this.columns) {
      this.columns = DataMap.getColumnsFromTable(this.tableName);
    }
    this.formWrapper = new PopUpFormWrapper();
    this.createInputFields();
    this.show();
  }

  PopupForm.prototype.createInputFields = function() {
    var column, i, len, ref, results, value;
    if (!this.key) {
      this.keyColumn = DataMap.getColumnsFromTable(this.tableName, (function(_this) {
        return function(c) {
          return c.getSource() === _this.keyElement;
        };
      })(this)).pop();
      this.keyColumn.required = true;
      this.columns.unshift(this.keyColumn);
    }
    this.columns = $.unique(this.columns);
    ref = this.columns;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      column = ref[i];
      if (column.getSource() === this.keyElement) {
        this.keyColumn = column;
      }
      value = this.key ? DataMap.getDataField(this.tableName, this.key, column.getSource()) : null;
      if (this.defaults && this.defaults[column.getSource()]) {
        value = this.defaults[column.getSource()];
      }
      results.push(this.formWrapper.addInput(column.getSource(), column.getName(), value, column.getType(), column.getOptions()));
    }
    return results;
  };

  PopupForm.prototype.onButton2 = function(e, form) {
    var column, i, invalidColumns, j, len, len1, ref, ref1, valid;
    valid = true;
    invalidColumns = [];
    ref = this.columns;
    for (i = 0, len = ref.length; i < len; i++) {
      column = ref[i];
      if (column.required && (!form[column.getSource()] || form[column.getSource()].length === 0)) {
        valid = false;
        invalidColumns.push(column.getName());
      }
    }
    if (!valid) {
      console.log("Error:", invalidColumns + " are required");
      return false;
    } else {
      if (this.key) {
        ref1 = this.columns;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          column = ref1[j];
          DataMap.getDataMap().updatePathValue(["", this.tableName, this.key, column.getSource()].join("/"), form[column.getSource()]);
        }
        return this.hide();
      } else {
        if (this.onCreateNew(this.tableName, form)) {
          DataMap.addData(this.tableName, form[this.keyElement], form);
          return this.hide();
        }
      }
    }
  };

  return PopupForm;

})(ModalDialog);
var TableViewColButton,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TableViewColButton = (function(superClass) {
  extend(TableViewColButton, superClass);

  function TableViewColButton(tableName, id) {
    this.tableName = tableName;
    this.id = id;
    this.UpdateSortIcon = bind(this.UpdateSortIcon, this);
    this.RenderHeaderHorizontal = bind(this.RenderHeaderHorizontal, this);
    this.RenderHeader = bind(this.RenderHeader, this);
    this.getWidth = bind(this.getWidth, this);
    this.getEditable = bind(this.getEditable, this);
    this.getClickable = bind(this.getClickable, this);
    this.getAlign = bind(this.getAlign, this);
    this.getFormatterName = bind(this.getFormatterName, this);
    this.getSource = bind(this.getSource, this);
    this.getOrder = bind(this.getOrder, this);
    this.getName = bind(this.getName, this);
    this.render = bind(this.render, this);
    this.visible = true;
    this.width = 60;
    this.sort = 0;
    this.name = this.id;
  }

  TableViewColButton.prototype.render = function(val) {
    return this.id;
  };

  TableViewColButton.prototype.getName = function() {
    return this.name;
  };

  TableViewColButton.prototype.getOrder = function() {
    return 99;
  };

  TableViewColButton.prototype.getSource = function() {
    if (this.source != null) {
      return this.source;
    }
    return this.id;
  };

  TableViewColButton.prototype.getFormatterName = function() {
    return "table_button";
  };

  TableViewColButton.prototype.getAlign = function() {
    return "center";
  };

  TableViewColButton.prototype.getClickable = function() {
    return true;
  };

  TableViewColButton.prototype.getEditable = function() {
    return false;
  };

  TableViewColButton.prototype.getWidth = function() {
    return this.width;
  };

  TableViewColButton.prototype.RenderHeader = function(parent, location) {
    parent.html(this.getName());
    parent.addClass("text-center");
    parent.addClass("tableHeaderField");
    return parent;
  };

  TableViewColButton.prototype.RenderHeaderHorizontal = function(parent, location) {
    parent.html(this.tableName);
    parent.addClass("text-center");
    parent.addClass("tableHeaderFieldHoriz");
    return parent;
  };

  TableViewColButton.prototype.UpdateSortIcon = function(newSort) {
    return true;
  };

  return TableViewColButton;

})(TableViewColBase);
var TableViewColCheckbox,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TableViewColCheckbox = (function(superClass) {
  extend(TableViewColCheckbox, superClass);

  function TableViewColCheckbox(tableName) {
    this.tableName = tableName;
    this.UpdateSortIcon = bind(this.UpdateSortIcon, this);
    this.RenderHeaderHorizontal = bind(this.RenderHeaderHorizontal, this);
    this.RenderHeader = bind(this.RenderHeader, this);
    this.getWidth = bind(this.getWidth, this);
    this.getEditable = bind(this.getEditable, this);
    this.getOrder = bind(this.getOrder, this);
    this.getAlign = bind(this.getAlign, this);
    this.getFormatterName = bind(this.getFormatterName, this);
    this.getSource = bind(this.getSource, this);
    this.getName = bind(this.getName, this);
    this.visible = true;
    this.width = 32;
    this.sort = 0;
  }

  TableViewColCheckbox.prototype.getName = function() {
    return "row_selected";
  };

  TableViewColCheckbox.prototype.getSource = function() {
    return "row_selected";
  };

  TableViewColCheckbox.prototype.getFormatterName = function() {
    return "boolean";
  };

  TableViewColCheckbox.prototype.getAlign = function() {
    return "center";
  };

  TableViewColCheckbox.prototype.getOrder = function() {
    return -99;
  };

  TableViewColCheckbox.prototype.getEditable = function() {
    return false;
  };

  TableViewColCheckbox.prototype.getWidth = function() {
    return this.width;
  };

  TableViewColCheckbox.prototype.RenderHeader = function(parent, location) {
    if (this.visible === false) {
      return;
    }
    parent.addClass("checkable");
    parent.addClass("tableHeaderField");
    parent.html("");
    return parent;
  };

  TableViewColCheckbox.prototype.RenderHeaderHorizontal = function(parent, location) {
    if (this.visible === false) {
      return;
    }
    parent.addClass("checkable");
    parent.addClass("tableHeaderFieldHoriz");
    parent.html("Select Row");
    parent.el.css({
      "text-align": "right",
      "padding-right": 8,
      "border-right": "1px solid #CCCCCC",
      "background": "linear-gradient(to right, #fff, #f2f2f2);"
    });
    return parent;
  };

  TableViewColCheckbox.prototype.UpdateSortIcon = function(newSort) {
    return true;
  };

  return TableViewColCheckbox;

})(TableViewColBase);
var TableViewCol,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TableViewCol = (function(superClass) {
  extend(TableViewCol, superClass);

  function TableViewCol(tableName) {
    this.tableName = tableName;
    this.deduceColumnType = bind(this.deduceColumnType, this);
    this.deduceInitialColumnType = bind(this.deduceInitialColumnType, this);
    this.UpdateSortIcon = bind(this.UpdateSortIcon, this);
    this.RenderHeaderHorizontal = bind(this.RenderHeaderHorizontal, this);
    this.RenderHeader = bind(this.RenderHeader, this);
    this.getWidth = bind(this.getWidth, this);
    this.getAutoSize = bind(this.getAutoSize, this);
    this.getAlign = bind(this.getAlign, this);
    this.getType = bind(this.getType, this);
    this.getEditable = bind(this.getEditable, this);
    this.getOptions = bind(this.getOptions, this);
    this.getClickable = bind(this.getClickable, this);
    this.getRequired = bind(this.getRequired, this);
    this.getAlwaysHidden = bind(this.getAlwaysHidden, this);
    this.getVisible = bind(this.getVisible, this);
    this.getIsCalculation = bind(this.getIsCalculation, this);
    this.getOrder = bind(this.getOrder, this);
    this.getSource = bind(this.getSource, this);
    this.getName = bind(this.getName, this);
    this.getRenderFunction = bind(this.getRenderFunction, this);
    this.internalMathRender = bind(this.internalMathRender, this);
    this.renderValue = bind(this.renderValue, this);
    this.renderTooltip = bind(this.renderTooltip, this);
    this.changeColumn = bind(this.changeColumn, this);
    this.data = {};
  }

  TableViewCol.prototype.changeColumn = function(varName, value) {
    if (this.data[varName] === value) {
      return;
    }
    if (varName === "renderFunction") {
      this.renderFunctionCache = null;
      this.render = value;
    }
    this.data[varName] = value;
    delete this.formatter;
    delete this.actualWidth;
    return true;
  };

  TableViewCol.prototype.renderTooltip = function(row, value, tooltipWindow) {
    var f;
    f = this.getFormatter();
    if ((f != null) && (f.renderTooltip != null)) {
      console.log("Checking ", f.renderTooltip);
      return f.renderTooltip(row, value, tooltipWindow);
    } else {
      console.log("renderTooltip formatter not found:", f);
    }
    return false;
  };

  TableViewCol.prototype.renderValue = function(value, keyValue, row) {
    var f;
    f = this.getRenderFunction();
    if (f != null) {
      return f(value, this.tableName, this.getSource(), keyValue, row);
    }
    f = this.getFormatter();
    if (f != null) {
      return f.format(value, this.getOptions(), this.tableName, keyValue);
    }
    return value;
  };

  TableViewCol.prototype.internalMathRender = function(a, b, c) {
    console.log("INTERNAL MATH RENDER:", this.data, "a=", a, "b=", b, "c=", c);
    return "X";
  };

  TableViewCol.prototype.getRenderFunction = function() {
    var template;
    if (this.renderFunctionCache != null) {
      return this.renderFunctionCache;
    }
    if (this.data.renderCode == null) {
      return null;
    }
    if (typeof this.data.renderCode === "string" && this.data.renderCode.charAt(0) === '=') {
      return this.internalMathRender;
    }
    template = 'try {  // toStringWrapper\nXXCODEXX\n} catch (e) { console.log("Render error:",e); console.log("val=",val,"tableName=",tableName,"fieldName=",fieldName,"id=",id); return "Error"; }';
    this.renderFunctionCache = new Function("val", "tableName", "fieldName", "id", "row", template.replace("XXCODEXX", renderText));
    return this.renderFunctionCache;
  };

  TableViewCol.prototype.getName = function() {
    return this.data.name;
  };

  TableViewCol.prototype.getSource = function() {
    return this.data.source;
  };

  TableViewCol.prototype.getOrder = function() {
    return this.data.order;
  };

  TableViewCol.prototype.getIsCalculation = function() {
    if ((this.data != null) && (this.data.calculation != null) && this.data.calculation === true) {
      return true;
    }
    if (this.getRenderFunction() !== null) {
      return true;
    }
    return false;
  };

  TableViewCol.prototype.getVisible = function() {
    if (this.getAlwaysHidden() === true) {
      return false;
    }
    if ((this.data.visible != null) && this.data.visible === true) {
      return true;
    }
    if ((this.data.visible != null) && this.data.visible === false) {
      return false;
    }
    if ((this.isGrouped != null) && this.isGrouped === true) {
      return false;
    }
    return true;
  };

  TableViewCol.prototype.getAlwaysHidden = function() {
    if ((this.data.hideable != null) && this.data.hideable === true) {
      return true;
    }
    return false;
  };

  TableViewCol.prototype.getRequired = function() {
    if ((this.data.required != null) && this.data.required === true) {
      return true;
    }
    return false;
  };

  TableViewCol.prototype.getClickable = function() {
    var f;
    if ((this.clickable != null) && this.clickable === true) {
      return true;
    }
    if ((this.clickable != null) && this.clickable === false) {
      return false;
    }
    if ((this.data.clickable != null) && this.data.clickable === true) {
      return true;
    }
    if ((this.data.clickable != null) && this.data.clickable === false) {
      return false;
    }
    f = this.getFormatter();
    if ((f != null) && (f.clickable != null) && f.clickable === true) {
      return true;
    }
    return false;
  };

  TableViewCol.prototype.getOptions = function() {
    if (this.data.options != null) {
      return this.data.options;
    }
    return null;
  };

  TableViewCol.prototype.getEditable = function() {
    return this.data.editable;
  };

  TableViewCol.prototype.getType = function() {
    if (this.data.type != null) {
      return this.data.type;
    }
    return "text";
  };

  TableViewCol.prototype.getAlign = function() {

    /*	
    		if @data.align? and @data.align.length > 0
    			return @data.align
     */
    var f;
    f = this.getFormatter();
    if ((f != null) && (f.align != null)) {
      return f.align;
    }
    return null;
  };

  TableViewCol.prototype.getAutoSize = function() {
    var width;
    if ((this.data.autosize != null) && this.data.autosize === true) {
      return true;
    }
    width = this.getWidth();
    if ((width != null) && width > 0) {
      return false;
    }
    return true;
  };

  TableViewCol.prototype.getWidth = function() {
    var f;
    if (typeof this.data.width === "string") {
      this.data.width = parseInt(this.data.width);
    }
    if (this.data.width === 0 || this.data.width === '0px' || this.data.width === "" || (this.data.width == null)) {
      f = this.getFormatter();
      if ((f != null) && (f.width != null) && f.width > 0) {
        return f.width;
      }
      return null;
    }
    return this.data.width;
  };

  TableViewCol.prototype.RenderHeader = function(parent, location) {
    var html;
    if (this.visible === false) {
      return;
    }
    html = this.getName();
    if (this.sort === -1) {
      html += "<i class='pull-right fa fa-sort-down'></i>";
    } else if (this.sort === 1) {
      html += "<i class='pull-right fa fa-sort-up'></i>";
    }
    parent.html(html);
    parent.addClass("tableHeaderField");
    return parent;
  };

  TableViewCol.prototype.RenderHeaderHorizontal = function(parent, location) {
    if (this.visible === false) {
      return;
    }
    parent.html(this.getName());
    parent.addClass("tableHeaderFieldHoriz");
    parent.el.css({
      "text-align": "right",
      "padding-right": 8,
      "border-right": "1px solid #CCCCCC",
      "background-color": "linear-gradient(to right, #fff, #f2f2f2);"
    });
    this.sort = 0;
    return parent;
  };

  TableViewCol.prototype.UpdateSortIcon = function(newSort) {
    this.sort = newSort;
    this.tagSort.removeClass("fa-sort");
    this.tagSort.removeClass("fa-sort-up");
    this.tagSort.removeClass("fa-sort-down");
    if (this.sort === -1) {
      this.tagSort.addClass("fa-sort-down");
    } else if (this.sort === 0) {
      this.tagSort.addClass("fa-sort");
    } else if (this.sort === 1) {
      this.tagSort.addClass("fa-sort-up");
    }
    return true;
  };

  TableViewCol.prototype.deduceInitialColumnType = function() {
    var reDistance, reYear;
    reYear = /year/i;
    reDistance = /distance/i;
    this.data.skipDeduce = false;
    this.data.deduceAttempts = 0;
    this.data.foundOnlyNumbers = true;
    if (/ Date/i.test(this.data.name)) {
      this.changeColumn("type", "age");
      this.changeColumn("width", 110);
      this.changeColumn("align", "left");
      this.data.skipDeduce = true;
      return;
    }
    if (/Date/i.test(this.data.name)) {
      this.changeColumn("type", "datetime");
      this.changeColumn("width", 110);
      this.changeColumn("align", "left");
      this.data.skipDeduce = true;
      return;
    }
    if (/ Price/i.test(this.data.name)) {
      this.changeColumn("type", "money");
      this.changeColumn("width", 90);
      this.changeColumn("align", "right");
      this.data.skipDeduce = true;
      return;
    }
    if (/Is /i.test(this.data.name)) {
      this.changeColumn("type", "boolean");
      this.changeColumn("width", 60);
      this.changeColumn("align", "left");
      this.data.skipDeduce = true;
      return;
    }
    if (/^Is/i.test(this.data.name)) {
      this.changeColumn("type", "boolean");
      this.changeColumn("width", 60);
      this.changeColumn("align", "left");
      this.data.skipDeduce = true;
      return;
    }
    if (reYear.test(this.data.name)) {
      this.changeColumn("type", "int");
      this.changeColumn("options", '####');
      this.changeColumn("width", 50);
      this.changeColumn("align", "right");
      this.data.skipDeduce = true;
      return;
    }
    if (reDistance.test(this.data.name)) {
      this.changeColumn("type", "distance");
      this.changeColumn("width", 66);
      this.changeColumn("align", "right");
      this.data.skipDeduce = true;
      return;
    }
    if (this.data.name === "id") {
      this.changeColumn("type", "text");
      this.changeColumn("width", null);
      this.changeColumn("visible", false);
      this.changeColumn("align", "left");
      this.changeColumn("name", "ID");
      return;
    }
    if (this.data.source === "lat" || this.data.source === "lon") {
      this.changeColumn("type", "decimal");
      this.changeColumn("width", 60);
      this.changeColumn("visible", true);
      this.changeColumn("align", "right");
      this.changeColumn("options", '#.#####');
      return;
    }
    if (/^sourcecode/i.test(this.data.name)) {
      this.changeColumn("type", "sourcecode");
      this.changeColumn("width", 60);
      this.changeColumn("align", "left");
      this.data.skipDeduce = true;
      return;
    }
    if (/^memo/i.test(this.data.name)) {
      this.changeColumn("type", "memo");
      this.changeColumn("width", 60);
      this.changeColumn("align", "left");
      this.data.skipDeduce = true;
      return;
    }
    if (/^imagelist/i.test(this.data.name)) {
      this.changeColumn("type", "imagelist");
      this.changeColumn("width", 60);
      this.changeColumn("align", "left");
      return;
    }
  };

  TableViewCol.prototype.deduceColumnType = function(newData) {
    if ((this.data.skipDeduce != null) && this.data.skipDeduce === true) {
      return null;
    }
    if (this.data.deduceAttempts++ > 50) {
      return null;
    }
    if (newData == null) {
      return null;
    }
    if (this.data.type !== "text") {
      return null;
    }
    if (typeof newData === "string") {
      if (reDate1.test(newData)) {
        this.changeColumn("type", "timeago");
        this.changeColumn("width", 80);
        this.data.skipDeduce = true;
        return;
      }
      if (reDate2.test(newData)) {
        this.changeColumn("type", "timeago");
        this.changeColumn("width", 110);
        this.data.skipDeduce = true;
        true;
      }
      if (/^https*/.test(newData)) {
        this.changeColumn("type", "link");
        this.changeColumn("align", "center");
        this.changeColumn("width", 80);
        this.data.skipDeduce = true;
        return true;
      }
      if (/^ftp*:/.test(newData)) {
        this.changeColumn("type", "link");
        this.changeColumn("align", "center");
        this.changeColumn("width", 80);
        this.data.skipDeduce = true;
        return true;
      }
      if (this.data.foundOnlyNumbers && reNumber.test(newData)) {
        this.changeColumn("type", "int");
        this.changeColumn("width", 80);
        return;
      }
      if (this.data.foundOnlyNumbers && reDecimal.test(newData)) {
        this.changeColumn("type", "decimal");
        this.changeColumn("width", 100);
        return;
      }
      if (this.data.foundOnlyNumbers) {
        this.changeColumn("type", "text");
        this.data.foundOnlyNumbers = false;
      }
    } else if (typeof newData === "number") {
      if (this.data.type === "text") {
        this.changeColumn("type", "int");
        this.changeColumn("align", "right");
        this.changeColumn("width", 80);
      }
      if (Math.floor(newData) !== Math.ceil(newData)) {
        this.changeColumn("type", "decimal");
        this.changeColumn("align", "right");
        this.changeColumn("width", 80);
        this.changeColumn("options", "#,###.###");
      }
    } else if (typeof newData === "boolean") {
      this.changeColumn("type", "boolean");
      this.changeColumn("width", 60);
      this.data.skipDeduce = true;
      return true;
    } else if (typeof newData === "object") {
      if (newData.getTime != null) {
        this.changeColumn("type", "age");
        this.changeColumn("width", "130");
        this.data.skipDeduce = true;
      } else if (Array.isArray(newData)) {
        this.changeColumn("type", "tags");
        this.changeColumn("autosize", true);
        this.changeColumn("width", null);
      } else {
        this.changeColumn("type", "simpleobject");
        this.changeColumn("width", null);
        this.data.skipDeduce = true;
      }
      return true;
    }
    return null;
  };

  return TableViewCol;

})(TableViewColBase);
var TableViewDetailed,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TableViewDetailed = (function(superClass) {
  extend(TableViewDetailed, superClass);

  TableViewDetailed.prototype.leftWidth = 100;

  TableViewDetailed.prototype.dataWidth = 120;

  function TableViewDetailed(elTableHolder, showCheckboxes) {
    this.elTableHolder = elTableHolder;
    this.showCheckboxes = showCheckboxes;
    this.setDataField = bind(this.setDataField, this);
    this.getCellType = bind(this.getCellType, this);
    this.getCellSelected = bind(this.getCellSelected, this);
    this.setHeaderField = bind(this.setHeaderField, this);
    this.getRowType = bind(this.getRowType, this);
    this.shouldAdvanceCol = bind(this.shouldAdvanceCol, this);
    this.isHeaderCell = bind(this.isHeaderCell, this);
    this.shouldSkipCol = bind(this.shouldSkipCol, this);
    this.shouldSkipRow = bind(this.shouldSkipRow, this);
    this.getCellFormatterName = bind(this.getCellFormatterName, this);
    this.getCellRecordID = bind(this.getCellRecordID, this);
    this.getCellSource = bind(this.getCellSource, this);
    this.getCellTablename = bind(this.getCellTablename, this);
    this.getCellAlign = bind(this.getCellAlign, this);
    this.getCellEditable = bind(this.getCellEditable, this);
    this.getCellStriped = bind(this.getCellStriped, this);
    this.getColWidth = bind(this.getColWidth, this);
    this.getTableVisibleCols = bind(this.getTableVisibleCols, this);
    this.getTableTotalCols = bind(this.getTableTotalCols, this);
    this.getTableTotalRows = bind(this.getTableTotalRows, this);
    TableViewDetailed.__super__.constructor.call(this, this.elTableHolder, this.showCheckboxes);
    this.showFilters = false;
    this.fixedHeader = true;
    this.showGroupPadding = false;
    this.showResize = false;
  }

  TableViewDetailed.prototype.getTableTotalRows = function() {
    var count;
    return count = Object.keys(this.colByNum).length;
  };

  TableViewDetailed.prototype.getTableTotalCols = function() {
    return this.totalAvailableRows + 1;
  };

  TableViewDetailed.prototype.getTableVisibleCols = function() {
    var colNum, location, maxWidth, totalCols, visColCount, x;
    if (this.cachedTotalVisibleCols != null) {
      return this.cachedTotalVisibleCols;
    }
    visColCount = 0;
    x = 0;
    colNum = this.offsetShowingLeft;
    maxWidth = this.getTableVisibleWidth();
    totalCols = this.getTableTotalCols();
    while (x < maxWidth && colNum < totalCols) {
      while ((colNum < totalCols) && this.shouldSkipCol(location)) {
        colNum++;
      }
      if (colNum >= totalCols) {
        break;
      }
      location = {
        colNum: colNum,
        visibleCol: visColCount
      };
      x = x + this.getColWidth(location);
      visColCount++;
      colNum++;
    }
    this.cachedTotalVisibleCols = visColCount;
    return visColCount;
  };

  TableViewDetailed.prototype.getColWidth = function(location) {
    if (this.showHeaders && location.visibleCol === 0) {
      return this.leftWidth;
    }
    if (this.totalAvailableRows === location.visibleCol) {
      return this.getTableVisibleWidth() - this.leftWidth - (this.dataWidth * (this.totalAvailableRows - 1));
    }
    return this.dataWidth;
  };

  TableViewDetailed.prototype.getCellStriped = function(location) {
    if (this.showHeaders && location.visibleCol === 0) {
      return false;
    }
    return location.visibleRow % 2 === 1;
  };

  TableViewDetailed.prototype.getCellEditable = function(location) {
    if (this.colByNum[location.rowNum] == null) {
      return null;
    }
    return this.colByNum[location.rowNum].getEditable();
  };

  TableViewDetailed.prototype.getCellAlign = function(location) {
    if (this.colByNum[location.rowNum] == null) {
      return null;
    }
    if (location.visibleCol === 0) {
      return 'right';
    }
    return 'left';
  };

  TableViewDetailed.prototype.getCellTablename = function(location) {
    if (this.colByNum[location.rowNum] == null) {
      return null;
    }
    return this.colByNum[location.rowNum].tableName;
  };

  TableViewDetailed.prototype.getCellSource = function(location) {
    if (this.colByNum[location.rowNum] == null) {
      return null;
    }
    return this.colByNum[location.rowNum].getSource();
  };

  TableViewDetailed.prototype.getCellRecordID = function(location) {
    if (this.rowDataRaw[location.colNum] == null) {
      return 0;
    }
    return this.rowDataRaw[location.colNum].id;
  };

  TableViewDetailed.prototype.getCellFormatterName = function(location) {
    if (this.colByNum[location.rowNum] == null) {
      return null;
    }
    return this.colByNum[location.rowNum].getFormatterName();
  };

  TableViewDetailed.prototype.shouldSkipRow = function(rowNum) {
    if (this.colByNum[location.rowNum] == null) {
      return true;
    }
    return false;
  };

  TableViewDetailed.prototype.shouldSkipCol = function(colNum) {
    if (this.rowDataRaw[location.colNum] == null) {
      return false;
    }
    if ((this.rowDataRaw[location.colNum].visible != null) && this.rowDataRaw[location.colNum].visible === false) {
      return true;
    }
    return false;
  };

  TableViewDetailed.prototype.isHeaderCell = function(location) {
    if (this.showHeaders && location.visibleCol === 0) {
      return true;
    }
    return false;
  };

  TableViewDetailed.prototype.shouldAdvanceCol = function(location) {
    if (this.showHeaders && location.visibleCol === 1) {
      return false;
    }
    return true;
  };

  TableViewDetailed.prototype.getRowType = function(location) {
    if (this.colByNum[location.rowNum] == null) {
      return "invalid'";
    }
    if (this.colByNum[location.rowNum] == null) {
      return "invalid";
    }
    return "data";
  };

  TableViewDetailed.prototype.setHeaderField = function(location) {
    location.cell.html("");
    if (this.colByNum[location.rowNum] == null) {
      return false;
    }
    this.colByNum[location.rowNum].RenderHeaderHorizontal(location.cell, location);
    return location.cell.setDataPath("/" + location.tableName + "/Header/" + location.sourceName);
  };

  TableViewDetailed.prototype.getCellSelected = function(location) {
    if ((this.rowDataRaw[location.colNum] != null) && this.rowDataRaw[location.colNum].row_selected) {
      return true;
    }
    return false;
  };

  TableViewDetailed.prototype.getCellType = function(location) {
    if (this.isHeaderCell(location)) {
      return "locked";
    }
    if ((location.colNum == null) || (this.rowDataRaw[location.colNum] == null)) {
      console.log("detail return invalid 1", location.colNum);
      return "invalid";
    }
    if (this.rowDataRaw[location.colNum] == null) {
      console.log("detail return invalid 2");
      return "invalid";
    }
    if (this.rowDataRaw[location.colNum].type != null) {
      return this.rowDataRaw[location.colNum].type;
    }
    return "data";
  };

  TableViewDetailed.prototype.setDataField = function(location) {
    var col, displayValue;
    col = this.colByNum[location.rowNum];
    if (col.getSource() === "row_selected") {
      if (this.getRowSelected(this.rowDataRaw[location.colNum].id)) {
        location.cell.html(this.imgChecked);
      } else {
        location.cell.html(this.imgNotChecked);
      }
    } else if (col.render != null) {
      location.cell.html(col.render(this.rowDataRaw[location.colNum][col.getSource()], this.rowDataRaw[location.colNum]));
    } else {
      displayValue = DataMap.getDataFieldFormatted(col.tableName, this.rowDataRaw[location.colNum].id, col.getSource());
      location.cell.html(displayValue);
    }
    return true;
  };

  return TableViewDetailed;

})(TableView);
var WidgetBase, WidgetTag, globalTagData, globalTagID, globalTagPath,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

globalTagData = {};

globalTagPath = {};

globalTagID = 0;

WidgetTag = (function() {
  WidgetTag.getDataFromEvent = function(e) {
    var getFromElement, results;
    if ((e == null) || (e.target == null)) {
      return {};
    }
    results = {};
    results.coords = GlobalValueManager.GetCoordsFromEvent(e);
    getFromElement = function(results, target, level) {
      var id, ref, ref1, results1, value, varName;
      if ((target.parentElement != null) && level < 6) {
        getFromElement(results, target.parentElement, level + 1);
      }
      ref = target.dataset;
      for (varName in ref) {
        value = ref[varName];
        if (varName === "id") {
          continue;
        }
        results[varName] = value;
      }
      id = target.dataset.id;
      if ((id != null) && typeof id === "string") {
        id = parseInt(id);
      }
      if ((id != null) && typeof id === "number") {
        if (globalTagData[id] != null) {
          ref1 = globalTagData[id];
          results1 = [];
          for (varName in ref1) {
            value = ref1[varName];
            results1.push(results[varName] = value);
          }
          return results1;
        }
      }
    };
    getFromElement(results, e.target, 0);
    return results;
  };

  function WidgetTag(tagName, classes, id, attributes) {
    this.destroy = bind(this.destroy, this);
    this.bindToPath = bind(this.bindToPath, this);
    this.renderField = bind(this.renderField, this);
    this.bind = bind(this.bind, this);
    this.setView = bind(this.setView, this);
    this.on = bind(this.on, this);
    this.find = bind(this.find, this);
    this.position = bind(this.position, this);
    this.move = bind(this.move, this);
    this.hide = bind(this.hide, this);
    this.show = bind(this.show, this);
    this.val = bind(this.val, this);
    this.html = bind(this.html, this);
    this.text = bind(this.text, this);
    this.onResize = bind(this.onResize, this);
    this.append = bind(this.append, this);
    this.appendTo = bind(this.appendTo, this);
    this.offset = bind(this.offset, this);
    this.outerHeight = bind(this.outerHeight, this);
    this.outerWidth = bind(this.outerWidth, this);
    this.width = bind(this.width, this);
    this.height = bind(this.height, this);
    this.removeClass = bind(this.removeClass, this);
    this.addClass = bind(this.addClass, this);
    this.resetClasses = bind(this.resetClasses, this);
    this.setClassOne = bind(this.setClassOne, this);
    this.setClass = bind(this.setClass, this);
    this.setAttribute = bind(this.setAttribute, this);
    this.setAbsolute = bind(this.setAbsolute, this);
    this.getZ = bind(this.getZ, this);
    this.setZ = bind(this.setZ, this);
    this.getDataValue = bind(this.getDataValue, this);
    this.setDataValue = bind(this.setDataValue, this);
    this.setDataPath = bind(this.setDataPath, this);
    this.resetDataValues = bind(this.resetDataValues, this);
    this.addDiv = bind(this.addDiv, this);
    this.getChildren = bind(this.getChildren, this);
    this.add = bind(this.add, this);
    this.getTag = bind(this.getTag, this);
    var attName, attValue;
    this.el = $(document.createElement(tagName));
    this.element = this.el[0];
    this.gid = globalTagID++;
    if (id != null) {
      this.el.attr("id", id);
      this.id = id;
    }
    if (classes != null) {
      this.el.attr("class", classes);
      this.classes = classes.split(' ');
    } else {
      this.classes = [];
    }
    this.children = [];
    this.visible = true;
    this.isAbsolute = false;
    this.element.dataset.id = this.gid;
    if (attributes != null) {
      for (attName in attributes) {
        attValue = attributes[attName];
        this.el.attr(attName, attValue);
      }
    }
  }

  WidgetTag.prototype.getTag = function() {
    return this.el;
  };

  WidgetTag.prototype.add = function(tagName, classes, id, attributes) {
    var tag;
    tag = new WidgetTag(tagName, classes, id, attributes);
    tag.parent = this;
    this.el.append(tag.el);
    this.children.push(tag);
    return tag;
  };

  WidgetTag.prototype.getChildren = function() {
    return this.children;
  };

  WidgetTag.prototype.addDiv = function(classes, id, attributes) {
    return this.add("div", classes, id);
  };

  WidgetTag.prototype.resetDataValues = function() {
    var c, i, len, path, ref;
    if (globalTagData[this.gid] != null) {
      path = globalTagData[this.gid];
      if (path != null) {
        delete globalTagPath[path];
      }
      globalTagData[this.gid] = {};
    }
    ref = this.children;
    for (i = 0, len = ref.length; i < len; i++) {
      c = ref[i];
      c.resetDataValues();
    }
    return true;
  };

  WidgetTag.prototype.setDataPath = function(keyVal) {
    globalTagPath[keyVal] = this.gid;
    return this.setDataValue("path", keyVal);
  };

  WidgetTag.prototype.setDataValue = function(name, value) {
    if (!globalTagData[this.gid]) {
      globalTagData[this.gid] = {};
    }
    globalTagData[this.gid][name] = value;
    return this;
  };

  WidgetTag.prototype.getDataValue = function(name) {
    if (!globalTagData[this.gid]) {
      globalTagData[this.gid] = {};
    }
    return globalTagData[this.gid][name];
  };

  WidgetTag.prototype.setZ = function(newZIndex) {
    if (newZIndex == null) {
      newZIndex = "auto";
    }
    if ((this.isAbsolute == null) || this.isAbsolute !== true) {
      console.log("Warning: WidgetBase setting z index without absolute position");
    }
    return this.element.style.zIndex = newZIndex;
  };

  WidgetTag.prototype.getZ = function() {
    return this.element.style.zIndex;
  };

  WidgetTag.prototype.setAbsolute = function(newIsAbsolute) {
    if (newIsAbsolute == null) {
      newIsAbsolute = true;
    }
    if (newIsAbsolute === this.isAbsolute) {
      return;
    }
    if (newIsAbsolute) {
      this.element.style.position = "absolute";
    } else {
      this.element.style.position = newIsAbsolute;
    }
    this.isAbsolute = newIsAbsolute;
    return true;
  };

  WidgetTag.prototype.setAttribute = function(keyName, keyVal) {
    this.el.attr(keyName, keyVal);
    return this;
  };

  WidgetTag.prototype.setClass = function(className, enabled) {
    if (enabled === true) {
      return this.addClass(className);
    } else {
      return this.removeClass(className);
    }
  };

  WidgetTag.prototype.setClassOne = function(validClass, patternForGroup) {
    var foundInvalid, foundValid, i, len, name, newList, ref, updateRequired;
    if (typeof patternForGroup === "string") {
      patternForGroup = new RegExp(patternForGroup);
    }
    newList = [];
    foundValid = false;
    foundInvalid = false;
    updateRequired = false;
    ref = this.classes;
    for (i = 0, len = ref.length; i < len; i++) {
      name = ref[i];
      if (validClass === name) {
        foundValid = true;
        newList.push(validClass);
      } else if (patternForGroup.test(name)) {
        foundInvalid = true;
      } else {
        newList.push(name);
      }
    }
    if (foundInvalid) {
      this.classes = newList;
      updateRequired = true;
    }
    if (!foundValid && validClass !== null) {
      this.classes.push(validClass);
      updateRequired = true;
    }
    if (updateRequired) {
      this.element.className = this.classes.join(' ');
    }
    return true;
  };

  WidgetTag.prototype.resetClasses = function(newListText) {
    this.classes = newListText.split(" ");
    return this.element.className = this.classes.join(' ');
  };

  WidgetTag.prototype.addClass = function(className) {
    var cn, i, len, ref;
    ref = this.classes;
    for (i = 0, len = ref.length; i < len; i++) {
      cn = ref[i];
      if (cn === className) {
        return true;
      }
    }
    this.classes.push(className);
    this.element.className = this.classes.join(' ');
    return true;
  };

  WidgetTag.prototype.removeClass = function(className) {
    var cn, found, i, len, newList, ref;
    newList = [];
    found = false;
    ref = this.classes;
    for (i = 0, len = ref.length; i < len; i++) {
      cn = ref[i];
      if (cn === className) {
        found = true;
      } else {
        newList.push(cn);
      }
    }
    if (found) {
      this.classes = newList;
      this.element.className = this.classes.join(' ');
    }
    return true;
  };

  WidgetTag.prototype.height = function() {
    if (this.cachedHeight != null) {
      return this.cachedHeight;
    }
    this.cachedHeight = this.el.height();
    return this.cachedHeight;
  };

  WidgetTag.prototype.width = function() {
    if (this.cachedWidth != null) {
      return this.cachedWidth;
    }
    this.cachedWidth = this.el.width();
    return this.cachedWidth;
  };

  WidgetTag.prototype.outerWidth = function() {
    return this.el.outerWidth();
  };

  WidgetTag.prototype.outerHeight = function() {
    return this.el.outerHeight();
  };

  WidgetTag.prototype.offset = function() {
    return this.el.offset();
  };

  WidgetTag.prototype.appendTo = function(jqueryElement) {
    return $(jqueryElement).append(this.el);
  };

  WidgetTag.prototype.append = function(html) {
    console.log("Warning: WidgetTag append called adding ", html);
    return this.el.append($(html));
  };

  WidgetTag.prototype.onResize = function() {
    var c, i, len, ref;
    delete this.cachedWidth;
    delete this.cachedHeight;
    ref = this.children;
    for (i = 0, len = ref.length; i < len; i++) {
      c = ref[i];
      c.onResize();
    }
    if (this.view != null) {
      console.log("Resizing widget view to ", this.width(), this.height());
      this.view.onResize(this.width(), this.height());
    }
    return true;
  };

  WidgetTag.prototype.text = function(str) {
    if (str == null) {
      return !currentValue;
    }
    if (this.currentValue !== str) {
      this.currentValue = str;
      this.element.innerText = str;
    }
    return this;
  };

  WidgetTag.prototype.html = function(str) {
    if (str == null) {
      return this.currentValue;
    }
    if (this.currentValue !== str) {
      this.currentValue = str;
      if (/</.test(str)) {
        this.element.innerHTML = str;
      } else {
        this.element.innerText = str;
      }
    }
    return this;
  };

  WidgetTag.prototype.val = function(str) {
    if (str == null) {
      this.currentValue = this.el.val();
      return this.currentValue;
    }
    if (this.currentValue !== str) {
      this.currentValue = str;
      this.el.val(str);
    }
    return this;
  };

  WidgetTag.prototype.show = function() {
    if (this.visible !== true) {
      this.el.show();
    }
    this.visible = true;
    return this;
  };

  WidgetTag.prototype.hide = function() {
    if (this.visible === true) {
      this.el.hide();
    }
    this.visible = false;
    return this;
  };

  WidgetTag.prototype.move = function(x, y, w, h) {
    if (x !== this.x) {
      this.x = x;
      this.element.style.left = this.x + "px";
    }
    if (y !== this.y) {
      this.y = y;
      this.element.style.top = this.y + "px";
    }
    if (w !== this.w) {
      this.w = w;
      delete this.cachedWidth;
      this.element.style.width = this.w + "px";
    }
    if (h !== this.h) {
      this.h = h;
      delete this.cachedHeight;
      this.element.style.height = this.h + "px";
    }
    return this;
  };

  WidgetTag.prototype.position = function() {
    var pos;
    pos = this.el.position();
    return pos;
  };

  WidgetTag.prototype.find = function(str) {
    return this.el.find(str);
  };

  WidgetTag.prototype.on = function(eventName, callback) {
    return this.bind(eventName, callback);
  };

  WidgetTag.prototype.setView = function(viewName, viewCallback) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return doAppendView(viewName, _this.el).then(function(view) {
          if (viewCallback != null) {
            viewCallback(view);
          }
          _this.view = view;
          _this.onResize();
          return resolve(view);
        });
      };
    })(this));
  };

  WidgetTag.prototype.bind = function(eventName, callback) {
    this.el.unbind(eventName);
    this.el.bind(eventName, function(e) {
      var data, value, varName;
      data = WidgetTag.getDataFromEvent(e);
      for (varName in data) {
        value = data[varName];
        e[varName] = value;
      }
      if (callback(e)) {
        e.preventDefault();
        e.stopPropagation();
        return true;
      }
      return false;
    });
    return this;
  };

  WidgetTag.prototype.renderField = function(tableName, idValue, fieldName) {
    var className, classes, currentValue, dm, i, len, path, ref, ref1;
    if (tableName == null) {
      return this.el;
    }
    dm = DataMap.getDataMap();
    path = "/" + tableName + "/" + idValue + "/" + fieldName;
    currentValue = DataMap.getDataFieldFormatted(tableName, idValue, fieldName);
    if (currentValue === "") {
      return this.el;
    }
    classes = ["data"];
    if (((ref = dm.types[tableName]) != null ? (ref1 = ref.col[fieldName]) != null ? ref1.getEditable() : void 0 : void 0) === true) {
      this.bind('click', globalOpenEditor);
      classes.push("editable");
    }
    for (i = 0, len = classes.length; i < len; i++) {
      className = classes[i];
      this.addClass(className);
    }
    this.setAttribute('data-path', path);
    this.html(currentValue);
    return this.el;
  };

  WidgetTag.prototype.bindToPath = function(tableName, idValue, fieldName) {
    var dm, path;
    dm = DataMap.getDataMap();
    this.renderField(tableName, idValue, fieldName);
    path = "/" + tableName + "/" + idValue + "/" + fieldName;
    dm.on("new_data", (function(_this) {
      return function(table, id) {
        if (table === tableName && id === idValue) {
          return _this.renderField(tableName, idValue, fieldName);
        }
      };
    })(this));
    globalKeyboardEvents.on("change", (function(_this) {
      return function(pathChanged, newValue) {
        if (pathChanged === path) {
          return _this.renderField(tableName, idValue, fieldName);
        }
      };
    })(this));
    return true;
  };

  WidgetTag.prototype.destroy = function() {
    var c, i, len, ref, ref1, value, varName;
    if (this.el == null) {
      return;
    }
    ref = this.children;
    for (i = 0, len = ref.length; i < len; i++) {
      c = ref[i];
      c.destroy();
    }
    delete globalTagData(this.gid);
    delete globalTagPath(this.gid);
    this.el.remove();
    delete this.el;
    delete this.children;
    ref1 = this;
    for (varName in ref1) {
      value = ref1[varName];
      console.log("destroy " + this.gid + " var=" + varName + ", value=", value);
    }
    return true;
  };

  return WidgetTag;

})();

WidgetBase = (function(superClass) {
  extend(WidgetBase, superClass);

  function WidgetBase() {
    if (typeof document === "undefined" || document === null) {
      console.log("INVALID CALL: Document not ready");
    }
    this.children = [];
    this.el = $(document.createDocumentFragment());
  }

  return WidgetBase;

})(WidgetTag);
