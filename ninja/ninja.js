var AddressNormalizer, AddressParser, BusyDialog, DataFormatBoolean, DataFormatCurrency, DataFormatDate, DataFormatDateAge, DataFormatDateTime, DataFormatDistance, DataFormatEnum, DataFormatFloat, DataFormatInt, DataFormatNumber, DataFormatPercent, DataFormatText, DataFormatTimeAgo, DataFormatter, DataFormatterType, DataMap, DataMapper, DataMapperBuilder, DataSet, DataType, DataTypeCollection, ErrorMessageBox, FormField, FormWrapper, GlobalAddressNormalizer, GlobalAddressParser, GlobalStreetSuffixParser, GlobalValueManager, ModalDialog, ModalMessageBox, PopupMenu, PopupMenuCalendar, PopupWindow, PopupWindowTableConfiguration, StreetSuffixParser, TableView, TableViewCol, TableViewDetailed, e, globalDataFormatter, globalOpenEditor, initializeSimpleTooltips, root, setupSimpleTooltips, simpleTooltipTimer, substringMatcher,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.DataFormatter = DataFormatter = (function() {
  DataFormatter.prototype.formats = {};

  DataFormatter.getNumber = function(data) {
    var result;
    if (data == null) {
      return 0;
    }
    if (typeof data === "number") {
      return data;
    }
    result = data.toString().replace(/[^0-9\.\-]/g, "");
    return result = parseFloat(result);
  };

  DataFormatter.getMoment = function(data) {
    if (data == null) {
      return null;
    }
    if ((data != null) && (data._isAMomentObject != null) && data._isAMomentObject) {
      return data;
    }
    if (typeof date !== "string") {
      return moment(data);
    }
    if (date.match(/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/)) {
      return moment(date, "YYYY-MM-DD HH:mm:ss");
    }
    if (date.match(/\d\d\d\d.\d\d.\d\d/)) {
      return moment(date, "YYYY-MM-DD");
    }
    if (date.match(/\d\d-\d\d-\d\d\d\d/)) {
      return moment(date, "MM-DD-YYYY");
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

DataFormatterType = (function() {
  function DataFormatterType() {
    this.openEditor = bind(this.openEditor, this);
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

  DataFormatterType.prototype.styleFormat = "";

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
    }
    this.editorShowing = true;
    return this.openEditor(elParent, left, top, width, height, currentValue, path);
  };

  DataFormatterType.prototype.saveValue = function(newValue) {
    console.log("Saving value", newValue);
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
        if (e.keyCode === 13) {
          _this.saveValue(_this.elEditor.val());
          _this.editorShowing = false;
          e.preventDefault();
          e.stopPropagation();
          _this.elEditor.hide();
          return false;
        }
        if (e.keyCode === 27) {
          _this.editorShowing = false;
          e.preventDefault();
          e.stopPropagation();
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

  DataFormatterType.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    if (!this.elEditor) {
      this.elEditor = $("<input />", {
        type: "text",
        "class": "dynamic_edit"
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
    return this.elEditor.focus();
  };

  return DataFormatterType;

})();

DataFormatText = (function(superClass) {
  extend(DataFormatText, superClass);

  function DataFormatText() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatText.__super__.constructor.apply(this, arguments);
  }

  DataFormatText.prototype.name = "text";

  DataFormatText.prototype.format = function(data, options, path) {
    if (data == null) {
      return "";
    }
    return data;
  };

  DataFormatText.prototype.unformat = function(data, path) {
    return data;
  };

  return DataFormatText;

})(DataFormatterType);

DataFormatInt = (function(superClass) {
  extend(DataFormatInt, superClass);

  function DataFormatInt() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatInt.__super__.constructor.apply(this, arguments);
  }

  DataFormatInt.prototype.name = "int";

  DataFormatInt.prototype.format = function(data, options, path) {
    return numeral(DataFormatter.getNumber(data)).format("#,###");
  };

  DataFormatInt.prototype.unformat = function(data, path) {
    return DataFormatter.getNumber(data);
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

  DataFormatNumber.prototype.format = function(data, options, path) {
    return numeral(DataFormatter.getNumber(data)).format("#,###.[##]");
  };

  DataFormatNumber.prototype.unformat = function(data, path) {
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
    return numeral(DataFormatter.getNumber(data)).format("#,###.##");
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

  DataFormatCurrency.prototype.format = function(data, options, path) {
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

  DataFormatPercent.prototype.format = function(data, options, path) {
    return numeral(DataFormatter.getNumber(data)).format('#,###.[##] %');
  };

  DataFormatPercent.prototype.unformat = function(data, path) {
    return DataFormatter.getNumber(data / 100.0);
  };

  return DataFormatPercent;

})(DataFormatterType);

DataFormatDate = (function(superClass) {
  extend(DataFormatDate, superClass);

  function DataFormatDate() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatDate.__super__.constructor.apply(this, arguments);
  }

  DataFormatDate.prototype.name = "date";

  DataFormatDate.prototype.width = 65;

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

DataFormatDateTime = (function(superClass) {
  extend(DataFormatDateTime, superClass);

  function DataFormatDateTime() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    this.openEditor = bind(this.openEditor, this);
    return DataFormatDateTime.__super__.constructor.apply(this, arguments);
  }

  DataFormatDateTime.prototype.name = "datetime";

  DataFormatDateTime.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    this.picker = new PopupMenuCalendar(currentValue, top, left);
    return this.picker.onChange = (function(_this) {
      return function(newValue) {
        return _this.recordChange(_this.name, newValue);
      };
    })(this);
  };

  true;

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
    return DataFormatDateAge.__super__.constructor.apply(this, arguments);
  }

  DataFormatDateAge.prototype.name = "age";

  DataFormatDateAge.prototype.width = 135;

  DataFormatDateAge.prototype.format = function(data, options, path) {
    var age, html, m;
    m = DataFormatter.getMoment(data);
    if (m == null) {
      return "&mdash;";
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

  DataFormatEnum.prototype.openEditor = function(elParent, left, top, width, height, currentValue, path) {
    var i, o, p, ref;
    p = new PopupMenu("Options", left, top);
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
      return "&mdash;";
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

  DataFormatDistance.prototype.width = 80;

  DataFormatDistance.prototype.format = function(data, options, path) {
    var ft, mi, val;
    val = DataFormatter.getNumber(data);
    ft = 3280.8 * val;
    if (ft < 1000) {
      return numeral(ft).format("#,###") + " ft.";
    }
    mi = 0.621371 * val;
    return numeral(mi).format("#,###.##") + " mi.";
  };

  DataFormatDistance.prototype.unformat = function(data, path) {
    var val;
    val = DataFormatter.getNumber(data);
    return val * 3280.8;
  };

  return DataFormatDistance;

})(DataFormatterType);

DataFormatBoolean = (function(superClass) {
  extend(DataFormatBoolean, superClass);

  function DataFormatBoolean() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatBoolean.__super__.constructor.apply(this, arguments);
  }

  DataFormatBoolean.prototype.name = "boolean";

  DataFormatBoolean.prototype.width = 40;

  DataFormatBoolean.prototype.format = function(data, options, path) {
    if (data == null) {
      return "No";
    }
    if (data === null || data === 0) {
      return "No";
    }
    return "Yes";
  };

  DataFormatBoolean.prototype.unformat = function(data, path) {
    if (data == null) {
      return 0;
    }
    if (data === null || data === 0) {
      return 0;
    }
    if (data === "No" || data === "no" || data === "false" || data === "off") {
      return 0;
    }
    return 1;
  };

  return DataFormatBoolean;

})(DataFormatterType);

DataFormatTimeAgo = (function(superClass) {
  extend(DataFormatTimeAgo, superClass);

  function DataFormatTimeAgo() {
    this.unformat = bind(this.unformat, this);
    this.format = bind(this.format, this);
    return DataFormatTimeAgo.__super__.constructor.apply(this, arguments);
  }

  DataFormatTimeAgo.prototype.name = "timeago";

  DataFormatTimeAgo.prototype.width = 135;

  DataFormatTimeAgo.prototype.format = function(data, options, path) {
    var age, days, daysTxt, hrs, hrsText, min, stamp, txt;
    stamp = DataFormatter.getMoment(data);
    if (stamp === null) {
      if (val) {
        return val;
      }
      return "&mdash;";
    }
    age = moment().diff(stamp) / 1000;
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
      if (hrs > 0) {
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
} catch (_error) {
  e = _error;
  console.log("Exception while registering global Data Formatter:", e);
}

globalOpenEditor = function(e) {
  var path;
  path = $(e).attr("data-path");
  DataMap.getDataMap().editValue(path, e);
  return false;
};

root = typeof exports !== "undefined" && exports !== null ? exports : this;

DataMap = (function() {
  function DataMap() {
    this.updatePathValue = bind(this.updatePathValue, this);
    this.editValue = bind(this.editValue, this);
    this.data = {};
    this.types = {};
  }

  DataMap.getDataMap = function() {
    if (!root.globalDataMap) {
      root.globalDataMap = new DataMap();
    }
    return root.globalDataMap;
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

  DataMap.getColumnsFromTable = function(tableName, reduceFunction) {
    var col, columns, dm, i, j, keepColumn, len, ref;
    dm = DataMap.getDataMap();
    columns = [];
    if (!dm.types[tableName]) {
      return columns;
    }
    ref = dm.types[tableName].colList;
    for (j = 0, len = ref.length; j < len; j++) {
      i = ref[j];
      col = dm.types[tableName].col[i];
      keepColumn = true;
      if (reduceFunction != null) {
        keepColumn = reduceFunction(col);
      }
      if (keepColumn) {
        columns.push(col);
      }
    }
    return columns;
  };

  DataMap.getValuesFromTable = function(tableName, reduceFunction) {
    var dm, keepRow, key, obj, ref, results;
    dm = DataMap.getDataMap();
    if (dm.data[tableName] == null) {
      return [];
    }
    results = [];
    ref = dm.data[tableName];
    for (key in ref) {
      obj = ref[key];
      keepRow = true;
      if (reduceFunction != null) {
        keepRow = reduceFunction(obj);
      }
      if (keepRow) {
        results.push({
          key: key,
          table: tableName
        });
      }
    }
    return results;
  };

  DataMap.prototype.editValue = function(path, el) {
    var existingValue, fieldName, formatter, keyValue, parts, tableName;
    parts = path.split('/');
    tableName = parts[1];
    keyValue = parts[2];
    fieldName = parts[3];
    existingValue = this.data[tableName][keyValue][fieldName];
    console.log("Existing:", existingValue);
    formatter = this.types[tableName].col[fieldName].formatter;
    console.log("F=", formatter);
    formatter.editData(el, existingValue, path, this.updatePathValue);
    return true;
  };

  DataMap.prototype.updatePathValue = function(path, newValue) {
    var currentValue, existingValue, fieldName, formatter, keyValue, parts, result, tableName;
    parts = path.split('/');
    tableName = parts[1];
    keyValue = parts[2];
    fieldName = parts[3];
    existingValue = this.data[tableName][keyValue][fieldName];
    console.log("Compare ", existingValue, " to ", newValue);
    if (existingValue === newValue) {
      return true;
    }
    this.data[tableName][keyValue][fieldName] = newValue;
    result = $("[data-path='" + path + "']");
    if (result.length > 0) {
      currentValue = newValue;
      if ((this.types[tableName] != null) && (this.types[tableName].col[fieldName] != null)) {
        formatter = this.types[tableName].col[fieldName].formatter;
        currentValue = formatter.format(currentValue, this.types[tableName].col[fieldName].options, path);
      }
      result.html(currentValue).addClass("dataChanged");
    }
    return true;
  };

  DataMap.addData = function(tableName, keyValue, values) {
    var dm, path, value, varName;
    dm = DataMap.getDataMap();
    if (!dm.data[tableName]) {
      dm.data[tableName] = {};
    }
    if (!dm.data[tableName][keyValue]) {
      dm.data[tableName][keyValue] = values;
      return true;
    }
    for (varName in values) {
      value = values[varName];
      path = "/" + tableName + "/" + keyValue + "/" + varName;
      dm.updatePathValue(path, value);
    }
    return true;
  };

  DataMap.getDataField = function(tableName, keyValue, fieldName) {
    var dm;
    dm = DataMap.getDataMap();
    if ((dm.data[tableName] == null) || (dm.data[tableName][keyValue] == null)) {
      return "";
    }
    return dm.data[tableName][keyValue][fieldName];
  };

  DataMap.renderField = function(tagNam, tableName, fieldName, keyValue, extraClassName) {
    var className, currentValue, dm, formatter, html, otherhtml, path;
    dm = DataMap.getDataMap();
    path = "/" + tableName + "/" + keyValue + "/" + fieldName;
    currentValue = "";
    className = "data";
    if ((dm.data[tableName] != null) && (dm.data[tableName][keyValue] != null) && (dm.data[tableName][keyValue][fieldName] != null)) {
      currentValue = dm.data[tableName][keyValue][fieldName];
    }
    otherhtml = "";
    if ((dm.types[tableName] != null) && (dm.types[tableName].col[fieldName] != null)) {
      formatter = dm.types[tableName].col[fieldName].formatter;
      if ((formatter != null) && formatter) {
        currentValue = formatter.format(currentValue, dm.types[tableName].col[fieldName].options, path);
        className += " " + formatter.name;
      }
      if ((dm.types[tableName].col[fieldName].render != null) && typeof dm.types[tableName].col[fieldName].render === "function") {
        currentValue = dm.types[tableName].col[fieldName].render(currentValue, path);
      }
      if (dm.types[tableName].col[fieldName].editable) {
        otherhtml += " onClick='globalOpenEditor(this);' ";
        className += " editable";
      }
    }
    if ((extraClassName != null) && extraClassName.length > 0) {
      className += " " + extraClassName;
    }
    if ((currentValue == null) || currentValue === null) {
      currentValue = "";
    }
    html = ("<" + tagNam + " data-path='" + path + "' class='" + className + "' " + otherhtml + ">") + currentValue + ("</" + tagNam + ">");
    return html;
  };

  return DataMap;

})();

DataType = (function() {
  DataType.prototype.source = '';

  DataType.prototype.visible = false;

  DataType.prototype.editable = false;

  DataType.prototype.hideable = true;

  DataType.prototype.required = false;

  DataType.prototype.type = '';

  DataType.prototype.tooltip = '';

  DataType.prototype.formatter = null;

  DataType.prototype.displayFormat = null;

  function DataType() {}

  return DataType;

})();

DataTypeCollection = (function() {
  function DataTypeCollection(configName, cols) {
    this.configName = configName;
    this.configureColumns = bind(this.configureColumns, this);
    this.configureColumn = bind(this.configureColumn, this);
    this.col = {};
    this.colList = [];
    if (cols != null) {
      this.configureColumns(cols);
    }
  }

  DataTypeCollection.prototype.configureColumn = function(col) {
    var c, name, value;
    c = new DataType();
    for (name in col) {
      value = col[name];
      c[name] = value;
    }
    c.formatter = globalDataFormatter.getFormatter(col.type);
    c.extraClassName = "col_" + this.configName + "_" + col.source;
    if (typeof col.render === "function") {
      c.displayFormat = col.render;
    }
    this.col[c.source] = c;
    return this.colList.push(c.source);
  };

  DataTypeCollection.prototype.configureColumns = function(columns) {
    var col, css, i, j, len, ref, str;
    for (j = 0, len = columns.length; j < len; j++) {
      col = columns[j];
      this.configureColumn(col);
    }
    css = "";
    ref = this.col;
    for (i in ref) {
      col = ref[i];
      str = "";
      if ((col.width != null) && col.width) {
        str += "width : " + col.width + "px; ";
      }
      if ((col.align != null) && col.align) {
        str += "text-align : " + col.align;
      }
      if (str && str.length > 0) {
        css += "." + col.extraClassName + " {";
        css += str;
        css += "}\n";
      }
    }
    if (css) {
      $("head").append("<style type='text/css'>\n" + css + "\n</style>");
    }
    return true;
  };

  return DataTypeCollection;

})();

DataMapper = (function() {
  function DataMapper() {}

  return DataMapper;

})();

DataMapperBuilder = (function() {
  DataMapperBuilder.prototype.deserialize = function(txt) {
    try {
      this.mapData = JSON.parse(txt);
    } catch (_error) {
      e = _error;
      console.log("DataMapperBuilder, deserialize: ", e);
    }
    this.redrawDataTypes();
    return setTimeout((function(_this) {
      return function() {
        return console.log("test");
      };
    })(this), 1500);
  };

  DataMapperBuilder.prototype.serialize = function() {
    var text;
    text = JSON.stringify(this.mapData);
    return console.log("TEXT=", text);
  };

  DataMapperBuilder.prototype.addTransformRule = function(clickName, ruleType, pattern, dest) {
    var j, len, ref, t;
    console.log("addTransformRule('" + clickName + "','" + ruleType + "','" + pattern + "','" + dest + "');");
    if (this.mapData[clickName] == null) {
      return;
    }
    if (this.mapData[clickName].transform == null) {
      this.mapData[clickName].transform = [];
    }
    ref = this.mapData[clickName].transform;
    for (j = 0, len = ref.length; j < len; j++) {
      t = ref[j];
      if (t.type === ruleType && t.pattern === pattern) {
        t.dest = dest;
        this.redrawDataTypes();
        return true;
      }
    }
    this.mapData[clickName].transform.push({
      type: ruleType,
      pattern: pattern,
      dest: dest
    });
    this.redrawDataTypes();
    return true;
  };

  DataMapperBuilder.prototype.onClickMapPlus = function(e) {
    var clickName, dataType, idx, m, ref;
    e.stopPropagation();
    e.preventDefault();
    clickName = $(e.currentTarget).attr("box_name");
    console.log("CURRENT:", this.mapData[clickName]);
    ref = this.KnownFields.colList;
    for (idx in ref) {
      dataType = ref[idx];
      if (dataType.name === this.mapData[clickName].mapName) {
        console.log("KNOWN  :", dataType);
      }
    }
    m = new ModalDialog({
      showOnCreate: false,
      content: "Add a custom processing rule, mapping to field: ",
      position: "top",
      title: "Custom Rule",
      ok: "Save"
    });
    m.getForm().addTextInput("pattern", "Target Pattern");
    m.getForm().addTextInput("destination", "Map To");
    m.getForm().onSubmit = (function(_this) {
      return function(form) {
        console.log("Form=", form);
        _this.addTransformRule(clickName, "transform", form.pattern, form.destination);
        return true;
      };
    })(this);
    return m.show();
  };

  DataMapperBuilder.prototype.onClickMap = function(e) {
    var clickName, dataType, elBox, idx, pop, ref, results1;
    e.stopPropagation();
    e.preventDefault();
    clickName = $(e.currentTarget).attr("box_name");
    elBox = this.SourceFields[clickName];
    pop = new PopupMenu("Map '" + clickName + "'", e);
    pop.resize(400);
    pop.addItem("Edit Target", (function(_this) {
      return function(e, info) {
        return _this.onSelectEdit(clickName);
      };
    })(this));
    ref = this.KnownFields.colList;
    results1 = [];
    for (idx in ref) {
      dataType = ref[idx];
      if ((dataType.isSelected != null) && dataType.isSelected) {
        pop.addItem("Copy to " + dataType.name, (function(_this) {
          return function(e, info) {
            return _this.onSelectMap(info, clickName, "copy");
          };
        })(this), idx);
        results1.push(pop.addItem("Append to " + dataType.name, (function(_this) {
          return function(e, info) {
            return _this.onSelectMap(info, clickName, "append");
          };
        })(this), idx));
      } else {
        results1.push(void 0);
      }
    }
    return results1;
  };

  DataMapperBuilder.prototype.onSelectEdit = function(clickName) {
    var dataType, fieldNames, idx, m, ref;
    m = new ModalDialog({
      showOnCreate: false,
      content: "Type a field name or custom field",
      position: "top",
      title: "Field Mapping",
      ok: "Save"
    });
    fieldNames = [];
    ref = this.KnownFields.colList;
    for (idx in ref) {
      dataType = ref[idx];
      fieldNames.push(dataType.name);
    }
    m.getForm().addTextInput("dest", "Target Field").makeTypeahead(fieldNames);
    m.getForm().onSubmit = (function(_this) {
      return function(form) {
        var ref1;
        console.log("Submitted form, test value=", form.dest);
        ref1 = _this.KnownFields.colList;
        for (idx in ref1) {
          dataType = ref1[idx];
          if (form.dest === dataType.name) {
            dataType.mapdata.mapType = "copy";
            dataType.mapdata.mapSource = clickName;
            _this.mapData[clickName] = {
              mapType: "copy",
              mapSource: clickName,
              mapDest: dataType.source,
              mapName: dataType.name
            };
            _this.redrawDataTypes();
            m.hide();
            return;
          }
        }
        _this.mapData[clickName] = {
          mapType: "formula",
          mapSource: clickName,
          mapDest: form.dest,
          mapName: null
        };
        _this.redrawDataTypes();
        return m.hide();
      };
    })(this);
    return m.show();
  };

  DataMapperBuilder.prototype.onSelectMap = function(idx, clickName, action) {
    delete this.KnownFields.colList[idx].isSelected;
    this.KnownFields.colList[idx].el.removeClass("selected");
    this.KnownFields.colList[idx].mapdata.mapType = action;
    this.KnownFields.colList[idx].mapdata.mapSource = clickName;
    this.mapData[clickName] = {
      mapType: action,
      mapSource: clickName,
      mapDest: this.KnownFields.colList[idx].source,
      mapName: this.KnownFields.colList[idx].name
    };
    this.redrawDataTypes();
    return console.log("MAP=", this.mapData);
  };

  DataMapperBuilder.prototype.onSelectDatatype = function(e) {
    var idx;
    e.stopPropagation();
    e.preventDefault();
    idx = $(e.currentTarget).attr("idx");
    if (this.KnownFields.colList[idx].isSelected != null) {
      console.log("Remove ", idx);
      this.KnownFields.colList[idx].el.removeClass("selected");
      return delete this.KnownFields.colList[idx].isSelected;
    } else {
      console.log("Set ", idx);
      this.KnownFields.colList[idx].el.addClass("selected");
      return this.KnownFields.colList[idx].isSelected = true;
    }
  };

  DataMapperBuilder.prototype.removeAllSelected = function(exceptedIndex) {
    var dataType, idx, ref, results1;
    ref = this.KnownFields.colList;
    results1 = [];
    for (idx in ref) {
      dataType = ref[idx];
      if (idx !== exceptedIndex && (dataType.isSelected != null) && dataType.isSelected) {
        dataType.el.removeClass("selected");
        results1.push(delete dataType.isSelected);
      } else {
        results1.push(void 0);
      }
    }
    return results1;
  };

  DataMapperBuilder.prototype.redrawTransformRules = function(name, field) {
    var j, len, ref, results1, row, t, td;
    if (this.mapData[name].transform == null) {
      return false;
    }
    ref = this.mapData[name].transform;
    results1 = [];
    for (j = 0, len = ref.length; j < len; j++) {
      t = ref[j];
      if (field.elTransformTable == null) {
        td = $("<td colspan='2' />");
        field.elTransformTable = $("<table class='transformRuleTable' />");
        td.append(field.elTransformTable);
        field.elTransform.append(td);
        field.elTransfromElements = {};
      }
      if (field.elTransfromElements[t.name] == null) {
        row = $(this.templateRuleLine(t));
        results1.push(field.elTransfromElements[t.name] = field.elTransformTable.append(row));
      } else {
        results1.push(void 0);
      }
    }
    return results1;
  };

  DataMapperBuilder.prototype.redrawDataTypes = function() {
    var dataType, field, found, i, idx, mapdata, name, ref, ref1, ref2;
    ref = this.KnownFields.col;
    for (idx in ref) {
      dataType = ref[idx];
      found = false;
      ref1 = this.mapData;
      for (i in ref1) {
        mapdata = ref1[i];
        if (mapdata.mapName === dataType.name) {
          if (mapdata.mapType === "copy") {
            dataType.el.find("i").addClass("fa-tag");
            dataType.el.addClass("assigned");
            found = true;
          } else if (mapdata.mapType === "append") {
            dataType.el.find("i").addClass("fa-copy");
            dataType.el.addClass("assigned");
            found = true;
          }
        }
      }
      if (!found) {
        dataType.el.find("i").removeClass("fa-tag");
        dataType.el.find("i").removeClass("fa-copy");
        dataType.el.removeClass("assigned");
      }
    }
    ref2 = this.SourceFields;
    for (name in ref2) {
      field = ref2[name];
      found = true;
      if ((this.mapData[name] != null) && this.mapData[name].mapType === "copy") {
        field.mapBox.html("<i class='fa fa-fw fa-tag'/> Copy to " + this.mapData[name].mapDest);
        field.el.children().addClass("assigned");
        this.redrawTransformRules(name, field);
      } else if ((this.mapData[name] != null) && this.mapData[name].mapType === "append") {
        field.mapBox.html("<i class='fa fa-fw fa-copy'/> Append to " + this.mapData[name].mapDest);
        field.el.children().addClass("assigned");
        this.redrawTransformRules(name, field);
      } else if ((this.mapData[name] != null) && this.mapData[name].mapType === "formula") {
        field.mapBox.html("<i class='fa fa-fw fa-arrow-right'/> Custom to " + this.mapData[name].mapDest);
        field.el.children().addClass("assigned");
        this.redrawTransformRules(name, field);
      } else {
        found = false;
        field.mapBox.html("<i class='fa fa-fw'/> None");
        field.el.children().removeClass("assigned");
      }
      if (found) {
        field.mapBoxPlus.show();
      } else {
        field.mapBoxPlus.hide();
      }
    }
    this.serialize();
    return true;
  };

  DataMapperBuilder.prototype.setupKnownFields = function() {
    var dataType, idx, ref, results1;
    ref = this.KnownFields.colList;
    results1 = [];
    for (idx in ref) {
      dataType = ref[idx];
      results1.push(dataType.mapdata = {
        mapType: "none"
      });
    }
    return results1;
  };

  function DataMapperBuilder(sourceObj, knownFields, holder) {
    this.setupKnownFields = bind(this.setupKnownFields, this);
    this.redrawDataTypes = bind(this.redrawDataTypes, this);
    this.redrawTransformRules = bind(this.redrawTransformRules, this);
    this.removeAllSelected = bind(this.removeAllSelected, this);
    this.onSelectDatatype = bind(this.onSelectDatatype, this);
    this.onSelectMap = bind(this.onSelectMap, this);
    this.onSelectEdit = bind(this.onSelectEdit, this);
    this.onClickMap = bind(this.onClickMap, this);
    this.onClickMapPlus = bind(this.onClickMapPlus, this);
    this.addTransformRule = bind(this.addTransformRule, this);
    this.serialize = bind(this.serialize, this);
    this.deserialize = bind(this.deserialize, this);
    var codes, correctOrder, dataType, dataTypeName, el, elBox, elKnown, idx, j, k, label, len, name, ref, sampleData, value, w, yPos;
    try {
      this.mapData = {};
      this.SourceFields = {};
      this.KnownFields = knownFields;
      this.elMain = $(holder).append("<table class='dataMapperMain' />");
      this.elMain.css({
        width: "100%"
      });
      codes = (function() {
        var results1;
        results1 = [];
        for (k in sourceObj) {
          results1.push(k);
        }
        return results1;
      })();
      correctOrder = codes.sort(function(a, b) {
        if (sourceObj[a] && !sourceObj[b]) {
          return -1;
        }
        if (sourceObj[b] && !sourceObj[a]) {
          return 1;
        }
        if (a.toUpperCase() < b.toUpperCase()) {
          return -1;
        }
        if (a.toUpperCase() > b.toUpperCase()) {
          return 1;
        }
        return 0;
      });
      this.setupKnownFields();
      this.templateRuleLine = Handlebars.compile('<tr>\n<td class=\'ruleType\'> {{type}} </td>\n<td class=\'rulePattern\'> {{pattern}} </td>\n<td class=\'ruleDest\'> {{dest}} </td>\n<td class=\'ruleMinus\'> <i class=\'fa fa-minus\' /> </td>\n</tr>');
      yPos = 0;
      for (j = 0, len = correctOrder.length; j < len; j++) {
        name = correctOrder[j];
        value = sourceObj[name];
        label = $("<label />", {
          html: name
        });
        sampleData = $("<div />", {
          html: value,
          "class": "data"
        });
        elBox = {};
        elBox.name = name;
        elBox.value = value;
        elBox.el = $("<tr />", {
          id: "builder_" + name,
          "class": "mapColumn"
        });
        elBox.mapBox = $("<td />", {
          "class": "mapBox",
          html: "None",
          box_name: name
        });
        elBox.mapBoxPlus = $("<td />", {
          "class": "mapBoxPlus",
          html: "<i class='fa fa-fw fa-plus' />",
          box_name: name
        });
        elBox.mapBox.on('click', this.onClickMap);
        elBox.mapBoxPlus.on('click', this.onClickMapPlus);
        elBox.el.append(label);
        elBox.el.append(sampleData);
        elBox.el.append(elBox.mapBox);
        elBox.el.append(elBox.mapBoxPlus);
        elBox.el.css({
          padding: "4px",
          backgroundColor: "#eeeeee"
        });
        this.SourceFields[name] = elBox;
        elBox.elTransform = $("<tr />", {
          id: "tr_" + name,
          "class": "transformRules"
        });
        this.elMain.append(elBox.el);
        this.elMain.append(elBox.elTransform);
        yPos += 44;
      }
      elKnown = $("<div />", {
        id: "knownColumns",
        "class": "knownColumns"
      });
      elKnown.append($("<div />", {
        "class": "knownTitle",
        html: "Mappable Columns"
      }));
      ref = this.KnownFields.colList;
      for (idx in ref) {
        dataTypeName = ref[idx];
        dataType = this.KnownFields.col[dataTypeName];
        el = $("<div />", {
          "class": "knownItem",
          popname: dataType.source,
          idx: idx,
          html: "<i class='fa fa-fw' /> " + dataType.name
        });
        el.on("click", this.onSelectDatatype);
        dataType.el = el;
        elKnown.append(el);
      }
      this.elMain.append(elKnown);
      this.redrawDataTypes();
      w = this.elMain.width();
      this.elMain.css("width", w - 240);
    } catch (_error) {
      e = _error;
      console.log("Exception in DataMapperBuilder: ", e, e.stack);
    }
  }

  return DataMapperBuilder;

})();


/*

This class represents one set of data which means

    b)  A source for the data
 */

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
            var dm, i, key, o;
            if ((_this.subElement != null) && _this.subElement) {
              rawData = rawData[_this.subElement];
            }
            if (_this.useDataMap) {
              dm = DataMap.getDataMap();
            }
            for (i in rawData) {
              o = rawData[i];
              if (_this.keyElement != null) {
                key = o[_this.keyElement];
              } else {
                key = i;
              }
              if (_this.useDataMap) {
                DataMap.addData(_this.baseName, key, o);
              } else {
                _this.data[key] = o;
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

BusyDialog = (function() {
  BusyDialog.prototype.content = "Processing please wait";

  BusyDialog.prototype.showing = false;

  BusyDialog.prototype.busyStack = [];

  BusyDialog.prototype.callbackStack = [];

  function BusyDialog() {
    this.show = bind(this.show, this);
    this.showBusy = bind(this.showBusy, this);
    this.exec = bind(this.exec, this);
    this.finished = bind(this.finished, this);
    this.template = Handlebars.compile('<div class="hidex" id="pleaseWaitDialog">\n    <div class="modal-header">\n        <h1 id=\'pleaseWaitDialogTitle\'>{{content}}</h1>\n    </div>\n    <div class="modal-body">\n        <div class="progress progress-striped active">\n            <div class="bar" style="width: 100%;"></div>\n        </div>\n    </div>\n</div>');
    this.pleaseWaitHolder = $("body").append(this.template(this));
    this.elTitle = $("#pleaseWaitDialogTitle");
    this.modal = $("#pleaseWaitDialog");
    this.modal.hide();
  }

  BusyDialog.prototype.finished = function() {
    this.busyStack.pop();
    if (this.busyStack.length > 0) {
      return this.elTitle.html(this.busyStack[this.busyStack.length - 1]);
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

  BusyDialog.prototype.showBusy = function(strText, options) {
    var name, val;
    this.busyStack.push(strText);
    if (typeof options === "object") {
      for (name in options) {
        val = options[name];
        this[name] = val;
      }
    }
    if (this.showing) {
      console.log("Updating to ", strText);
      $("#pleaseWaitDialogTitle").html(strText);
      return;
    }
    this.showing = true;
    this.elTitle.html(strText);
    return this.show({
      position: "center"
    });
  };

  BusyDialog.prototype.show = function(options) {
    this.modal.show();
    return this.modal.css({
      'position': "fixed",
      left: (function(_this) {
        return function() {
          return ($(window).width() - _this.modal.width()) / 2;
        };
      })(this),
      'top': (function(_this) {
        return function() {
          return Math.max(0, $(window).scrollTop() + ($(window).height() - _this.modal.height()) / 2);
        };
      })(this)
    });
  };

  return BusyDialog;

})();

$(function() {
  return window.globalBusyDialog = new BusyDialog();
});

substringMatcher = function(strs) {
  return function(q, cb) {
    var j, len, matches, o, substrRegex;
    matches = [];
    substrRegex = new RegExp(q, 'i');
    for (j = 0, len = strs.length; j < len; j++) {
      o = strs[j];
      if (substrRegex.test(o)) {
        matches.push(o);
      }
    }
    return cb(matches);
  };
};

FormField = (function() {
  function FormField(fieldName1, label1, type) {
    this.fieldName = fieldName1;
    this.label = label1;
    this.type = type;
    this.onAfterShow = bind(this.onAfterShow, this);
    this.onPressEscape = bind(this.onPressEscape, this);
    this.onPressEnter = bind(this.onPressEnter, this);
    this.makeTypeahead = bind(this.makeTypeahead, this);
    this.getHtml = bind(this.getHtml, this);
    this.html = this.getHtml();
  }

  FormField.prototype.getHtml = function() {
    return "<input name='" + this.fieldName + "' id='" + this.fieldName + "' type='" + this.type + "' class='form-control' />";
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
    }
  };

  return FormField;

})();

FormWrapper = (function() {
  function FormWrapper() {
    this.onAfterShow = bind(this.onAfterShow, this);
    this.onSubmitAction = bind(this.onSubmitAction, this);
    this.onSubmit = bind(this.onSubmit, this);
    this.getHtml = bind(this.getHtml, this);
    this.addTextInput = bind(this.addTextInput, this);
    this.fields = [];
    this.gid = "form" + GlobalValueManager.NextGlobalID();
    this.templateFormFieldText = Handlebars.compile('<div class="form-group">\n	<label for="{{fieldName}}"> {{label}} </label>\n	<input class="form-control" id="{{fieldName}}" name="{{fieldName}}">\n	<br>\n	<div id="{{fieldName}}error" class="text-danger"></div>\n</div>');
  }

  FormWrapper.prototype.addTextInput = function(fieldName, label, fnValidate) {
    var field;
    field = new FormField(fieldName, label, "text");
    this.fields.push(field);
    return field;
  };

  FormWrapper.prototype.getHtml = function() {
    var content, field, j, len, ref;
    content = "<form id='" + this.gid + "'>";
    ref = this.fields;
    for (j = 0, len = ref.length; j < len; j++) {
      field = ref[j];
      content += this.templateFormFieldText(field);
    }
    return content += "</form>";
  };

  FormWrapper.prototype.onSubmit = function() {
    return console.log("SUBMIT");
  };

  FormWrapper.prototype.onSubmitAction = function(e) {
    var field, j, len, ref;
    ref = this.fields;
    for (j = 0, len = ref.length; j < len; j++) {
      field = ref[j];
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
    var field, firstField, j, len, ref;
    this.elForm = $("#" + this.gid);
    firstField = null;
    ref = this.fields;
    for (j = 0, len = ref.length; j < len; j++) {
      field = ref[j];
      field.el = this.elForm.find("#" + field.fieldName);
      field.onAfterShow();
      if (!firstField) {
        firstField = field;
        firstField.el.focus();
      }
      field.onPressEnter = (function(_this) {
        return function(e) {
          return _this.onSubmitAction(e);
        };
      })(this);
    }
    this.elForm.on("submit", this.onSubmitAction);
    return true;
  };

  return FormWrapper;

})();

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
    this.template = Handlebars.compile('<div class="modal" id="modal{{gid}}" tabindex="-1" role="dialog" aria-hidden="true" style="display: none;">\n	<div class="modal-dialog">\n		<div class="modal-content">\n			<div class="block block-themed block-transparent remove-margin-b">\n				<div class="block-header bg-primary-dark">\n					<ul class="block-options">\n						<li>\n							<button data-dismiss="modal" type="button"><i class="si si-close"></i></button>\n						</li>\n					</ul>\n					<h3 class="block-title">{{title}}</h3>\n				</div>\n				<div class="block-content">\n					<p>\n					{{{content}}}\n					</p>\n				</div>\n			</div>\n\n			{{#if showFooter}}\n			<div class="modal-footer">\n				{{#if close}}\n				<button class="btn btn-sm btn-default btn1" type="button" data-dismiss="modal">{{close}}</button>\n				{{/if}}\n				{{#if ok}}\n				<button class="btn btn-sm btn-primary btn2" type="button" data-dismiss="modal"><i class="fa fa-check"></i> {{ok}}</button>\n				{{/if}}\n			</div>\n			{{/if}}\n\n		</div>\n	</div>\n</div>');
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
    if (this.formWrapper != null) {
      this.content += this.formWrapper.getHtml();
    }
    html = this.template(this);
    $("body").append(html);
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
        _this.modal.find("input").each(function(idx, el) {
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

  return ModalDialog;

})();

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

window.popupMenuVisible = false;

window.popupMenuHolder = null;

PopupMenu = (function() {
  PopupMenu.prototype.popupWidth = 300;

  PopupMenu.prototype.popupHeight = 0;

  PopupMenu.prototype.resize = function(popupWidth) {
    var height, width;
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
    if (this.y + this.popupHeight + 10 > height) {
      this.y = height - this.popupHeight - 10;
    }
    window.popupMenuHolder.css({
      left: this.x,
      top: this.y,
      width: this.popupWidth
    });
    window.popupMenuHolder.show();
    return true;
  };

  function PopupMenu(title1, x1, y1) {
    var html, id, values;
    this.title = title1;
    this.x = x1;
    this.y = y1;
    this.addItem = bind(this.addItem, this);
    this.setMultiColumn = bind(this.setMultiColumn, this);
    this.closeTimer = bind(this.closeTimer, this);
    this.resize = bind(this.resize, this);
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
    this.resize(300);
    this.colCount = 1;
    this.menuItems = {};
    this.menuData = {};
  }

  PopupMenu.prototype.closeTimer = function() {
    console.log("Popup Hide");
    window.popupMenuHolder.hide();
    window.popupMenuVisible = false;
    window.popupMenuTimer = 0;
    return false;
  };

  PopupMenu.prototype.setMultiColumn = function(colCount) {
    this.colCount = colCount;
    this.resize(600);
    return window.popupMenuHolder.addClass("multicol");
  };

  PopupMenu.prototype.addItem = function(name, callbackFunction, callbackData, className) {
    var id, link;
    id = GlobalValueManager.NextGlobalID();
    this.menuItems[id] = callbackFunction;
    this.menuData[id] = callbackData;
    if (typeof className === "undefined") {
      className = "item";
    }
    link = $("<li />", {
      'data-id': id,
      'class': className,
      'html': name
    });
    if (this.colCount > 0) {
      link.addClass("multicol");
    }
    link.on("click", (function(_this) {
      return function(e) {
        var dataId;
        e.preventDefault();
        e.stopPropagation();
        window.popupMenuHolder.hide();
        window.popupMenuVisible = false;
        dataId = $(e.target).attr("data-id");
        if (dataId) {
          _this.menuItems[dataId](e, _this.menuData[dataId]);
        }
        return true;
      };
    })(this));
    window.popupMenuHolder.append(link);
    return this.resize(this.popupWidth);
  };

  return PopupMenu;

})();

$(function() {
  $(document).on("click", (function(_this) {
    return function(e) {
      if (window.popupMenuVisible) {
        window.popupMenuHolder.hide();
        window.popupMenuVisible = false;
      }
      return true;
    };
  })(this));
  return $(document).on("keypress", (function(_this) {
    return function(e) {
      if (e.keyCode === 13) {
        if (window.popupMenuVisible) {
          window.popupMenuHolder.hide();
          window.popupMenuVisible = false;
        }
      }
      return true;
    };
  })(this));
});

window.popupCalendarVisible = false;

window.popupCalendarHolder = null;

PopupMenuCalendar = (function() {
  PopupMenuCalendar.prototype.popupWidth = 350;

  PopupMenuCalendar.prototype.popupHeight = 350 + 24 + 24;

  PopupMenuCalendar.prototype.onChange = function(newDate) {
    return console.log("Unhandled onChange in PopupMenuCalendar for date=", newDate);
  };

  PopupMenuCalendar.prototype.resize = function(popupWidth) {
    var height, width;
    this.popupWidth = popupWidth;
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
    if (this.y + this.popupHeight + 10 > height) {
      this.y = height - this.popupHeight - 10;
    }
    window.popupCalendarHolder.css({
      left: this.x,
      top: this.y,
      width: this.popupWidth,
      height: this.popupHeight
    });
    window.popupCalendarHolder.show();
    return true;
  };

  function PopupMenuCalendar(value1, x1, y1) {
    var html, id, values;
    this.value = value1;
    this.x = x1;
    this.y = y1;
    this.setupMonth = bind(this.setupMonth, this);
    this.recalcDays = bind(this.recalcDays, this);
    this.closeTimer = bind(this.closeTimer, this);
    this.resize = bind(this.resize, this);
    this.onChange = bind(this.onChange, this);
    if ((this.x != null) && this.x && (this.x.currentTarget != null) && this.x.currentTarget) {
      values = GlobalValueManager.GetCoordsFromEvent(this.x);
      this.x.stopPropagation();
      this.x.preventDefault();
      this.x = values.x - 150;
      this.y = values.y - 10;
    }
    this.title = "Select Date";
    this.theMoment = GlobalValueManager.GetMoment(this.value);
    if (typeof this.theMoment === "undefined" || this.theMoment === null) {
      this.showingMoment = moment();
    } else {
      this.showingMoment = moment(this.theMoment);
    }
    if (this.x < 0) {
      this.x = 0;
    }
    if (this.y < 0) {
      this.y = 0;
    }
    $(".PopupMenuCal").remove();
    window.popupCalendarVisible = false;
    id = GlobalValueManager.NextGlobalID();
    html = $("<div />", {
      "class": "PopupMenuCal",
      id: "popup" + id
    });
    window.popupCalendarHolder = $(html);
    window.popupMenuTimer = 0;
    $("body").append(window.popupCalendarHolder);
    $(window.popupCalendarHolder).on("mouseout", (function(_this) {
      return function(e) {
        if (window.popupCalendarVisible) {
          if (window.popupMenuTimer) {
            clearTimeout(window.popupMenuTimer);
          }
          window.popupMenuTimer = setTimeout(_this.closeTimer, 1750);
          false;
        }
        return true;
      };
    })(this));
    $(window.popupCalendarHolder).on("mouseover", (function(_this) {
      return function(e) {
        if (window.popupCalendarVisible) {
          if (window.popupMenuTimer) {
            clearTimeout(window.popupMenuTimer);
          }
          window.popupMenuTimer = 0;
        }
        return true;
      };
    })(this));
    this.setupMonth();
    window.popupCalendarVisible = true;
    this.recalcDays();
    this.resize(this.popupWidth);
    this.menuItems = {};
    this.menuData = {};
  }

  PopupMenuCalendar.prototype.closeTimer = function() {
    console.log("Popup Hide");
    if (typeof window.popupCalendarHolder !== "undefined" && window.popupCalendarHolder !== null) {
      window.popupCalendarHolder.remove();
      window.popupCalendarHolder = null;
    }
    window.popupCalendarVisible = false;
    window.popupMenuTimer = 0;
    return false;
  };

  PopupMenuCalendar.prototype.recalcDays = function() {
    var currentDay, currentMonth, currentYear, dayLetter, dayNum, j, monthNum, n, now, results1, selectedDayOfYear, selectedYear, today, todayOfYear, yearNum;
    today = moment();
    todayOfYear = today.dayOfYear();
    now = moment(this.showingMoment);
    currentMonth = now.month();
    currentYear = now.year();
    currentDay = now.date();
    selectedDayOfYear = -1;
    if (typeof this.theMoment !== "undefined" && this.theMoment !== null) {
      selectedDayOfYear = this.theMoment.dayOfYear();
      selectedYear = this.theMoment.year();
    }
    $("#calTitle").html(now.format("MMM, YYYY"));
    now = now.subtract(currentDay - 1, "days");
    now = now.subtract(now.day(), "days");
    results1 = [];
    for (n = j = 0; j <= 41; n = ++j) {
      dayLetter = now.day();
      dayNum = now.date();
      yearNum = now.year();
      monthNum = now.month();
      this.elDay[n].html(dayNum);
      this.elDay[n].removeClass("diffMonth");
      this.elDay[n].removeClass("today");
      this.elDay[n].removeClass("selected");
      if (monthNum !== currentMonth) {
        this.elDay[n].addClass("diffMonth");
      }
      if (now.dayOfYear() === todayOfYear && yearNum === today.year()) {
        this.elDay[n].addClass("today");
      }
      if (now.dayOfYear() === selectedDayOfYear && (yearNum = selectedYear)) {
        this.elDay[n].addClass("selected");
      }
      this.elDay[n].attr("date-value", now.format("YYYY-MM-DD"));
      results1.push(now.add(1, "day"));
    }
    return results1;
  };

  PopupMenuCalendar.prototype.setupMonth = function() {
    var calCompiled, calTemplate, html, j, n;
    calTemplate = '<table class=\'PopupCalendar\'>\n	<tr><td class=\'prev\' id=\'calPrevious\'> <i class=\'fa fa-angle-left\'></i> </td>\n		<td colspan=\'5\' id=\'calTitle\'> Something </td>\n		<td class=\'next\' id=\'calNext\'><i class=\'fa fa-angle-right\'></i> </td>\n	</tr>\n\n	<tr>\n	<th class=\'sun\'> Sun </th>\n	<th class=\'mon\'> Mon </th>\n	<th class=\'tue\'> Tue </th>\n	<th class=\'wed\'> Wed </th>\n	<th class=\'thu\'> Thu </th>\n	<th class=\'fri\'> Fri </th>\n	<th class=\'sat\'> Sat </th>\n	</tr>\n\n	<tr>\n	<td class=\'sun\' id=\'cal0\'> x </td>\n	<td class=\'mon\' id=\'cal1\'> x </td>\n	<td class=\'tue\' id=\'cal2\'> x </td>\n	<td class=\'wed\' id=\'cal3\'> x </td>\n	<td class=\'thu\' id=\'cal4\'> x </td>\n	<td class=\'fri\' id=\'cal5\'> x </td>\n	<td class=\'sat\' id=\'cal6\'> x </td>\n	</tr>\n\n	<tr>\n	<td class=\'sun\' id=\'cal7\'> x </td>\n	<td class=\'mon\' id=\'cal8\'> x </td>\n	<td class=\'tue\' id=\'cal9\'> x </td>\n	<td class=\'wed\' id=\'cal10\'> x </td>\n	<td class=\'thu\' id=\'cal11\'> x </td>\n	<td class=\'fru\' id=\'cal12\'> x </td>\n	<td class=\'sat\' id=\'cal13\'> x </td>\n	</tr>\n\n	<tr>\n	<td class=\'sun\' id=\'cal14\'> x </td>\n	<td class=\'mon\' id=\'cal15\'> x </td>\n	<td class=\'tue\' id=\'cal16\'> x </td>\n	<td class=\'wed\' id=\'cal17\'> x </td>\n	<td class=\'thu\' id=\'cal18\'> x </td>\n	<td class=\'fru\' id=\'cal19\'> x </td>\n	<td class=\'sat\' id=\'cal20\'> x </td>\n	</tr>\n\n	<tr>\n	<td class=\'sun\' id=\'cal21\'> x </td>\n	<td class=\'mon\' id=\'cal22\'> x </td>\n	<td class=\'tue\' id=\'cal23\'> x </td>\n	<td class=\'wed\' id=\'cal24\'> x </td>\n	<td class=\'thu\' id=\'cal25\'> x </td>\n	<td class=\'fru\' id=\'cal26\'> x </td>\n	<td class=\'sat\' id=\'cal27\'> x </td>\n	</tr>\n\n	<tr>\n	<td class=\'sun\' id=\'cal28\'> x </td>\n	<td class=\'mon\' id=\'cal29\'> x </td>\n	<td class=\'tue\' id=\'cal30\'> x </td>\n	<td class=\'wed\' id=\'cal31\'> x </td>\n	<td class=\'thu\' id=\'cal32\'> x </td>\n	<td class=\'fru\' id=\'cal33\'> x </td>\n	<td class=\'sat\' id=\'cal34\'> x </td>\n	</tr>\n\n	<tr>\n	<td class=\'sun\' id=\'cal35\'> x </td>\n	<td class=\'mon\' id=\'cal36\'> x </td>\n	<td class=\'tue\' id=\'cal37\'> x </td>\n	<td class=\'wed\' id=\'cal38\'> x </td>\n	<td class=\'thu\' id=\'cal39\'> x </td>\n	<td class=\'fru\' id=\'cal40\'> x </td>\n	<td class=\'sat\' id=\'cal41\'> x </td>\n	</tr>\n\n	<tr><td class=\'message\' id=\'calMessage\' colspan=7\'></td></tr>\n\n</table>';
    calCompiled = Handlebars.compile(calTemplate);
    html = calCompiled(this);
    window.popupCalendarHolder.append(html);
    $("#calNext").bind("click", (function(_this) {
      return function(e) {
        e.preventDefault();
        e.stopPropagation();
        _this.showingMoment.add(1, "month");
        _this.recalcDays();
        return false;
      };
    })(this));
    $("#calPrevious").bind("click", (function(_this) {
      return function(e) {
        e.preventDefault();
        e.stopPropagation();
        _this.showingMoment.subtract(1, "month");
        _this.recalcDays();
        return false;
      };
    })(this));
    this.elDay = {};
    for (n = j = 0; j <= 41; n = ++j) {
      this.elDay[n] = $("#cal" + n);
      this.elDay[n].bind("click toughbegin", (function(_this) {
        return function(e) {
          var val;
          val = $(e.target).attr("date-value");
          _this.onChange(val);
          return _this.closeTimer();
        };
      })(this));
      this.elDay[n].bind("mouseover", (function(_this) {
        return function(e) {
          var age, m, message, val;
          val = $(e.target).attr("date-value");
          m = moment(val);
          age = moment().diff(m);
          age = Math.trunc(age / 86400000);
          if (age === -1) {
            message = "1 day ago";
          } else if (age === 1) {
            message = "in 1 day";
          } else if (age < -1) {
            message = "in " + Math.abs(age) + " days";
          } else {
            message = Math.abs(age) + " days ago";
          }
          return _this.calMessage.html(val + " (" + message + ")");
        };
      })(this));
      this.elDay[n].bind("mouseout", (function(_this) {
        return function(e) {
          return _this.calMessage.html("");
        };
      })(this));
    }
    return this.calMessage = $("#calMessage");
  };

  return PopupMenuCalendar;

})();

$(function() {
  $(document).on("click", (function(_this) {
    return function(e) {
      if (window.popupCalendarVisible) {
        window.popupCalendarHolder.remove();
        window.popupCalendarVisible = false;
      }
      return true;
    };
  })(this));
  return $(document).on("keypress", function(e) {
    if (e.keyCode === 27) {
      if (window.popupCalendarVisible) {
        window.popupCalendarHolder.remove();
        window.popupCalendarVisible = false;
      }
    }
    return true;
  });
});

PopupWindow = (function() {
  PopupWindow.prototype.popupWidth = 600;

  PopupWindow.prototype.popupHeight = 400;

  PopupWindow.prototype.isVisible = false;

  PopupWindow.prototype.getBodyHeight = function() {
    var h;
    h = this.popupHeight;
    h -= 1;
    h -= 1;
    h -= this.windowTitle.height();
    return h;
  };

  PopupWindow.prototype.update = function() {
    return this.myScroll.refresh();
  };

  PopupWindow.prototype.open = function() {
    setTimeout((function(_this) {
      return function() {
        return _this.update();
      };
    })(this), 20);
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
    this.close();
    this.popupWindowHolder.remove();
    return true;
  };

  PopupWindow.prototype.center = function() {
    var height, width;
    width = $(window).width();
    height = $(window).height();
    this.x = (width - this.popupWidth) / 2;
    this.y = (height - this.popupHeight) / 2;
    return this.popupWindowHolder.css({
      left: this.x,
      top: this.y
    });
  };

  PopupWindow.prototype.resize = function(popupWidth, popupHeight) {
    var height, width;
    this.popupWidth = popupWidth;
    this.popupHeight = popupHeight;
    width = $(window).width();
    height = $(window).height();
    if (this.x === 0 && this.y === 0) {
      this.center();
    }
    if (this.x < 0) {
      this.x = 0;
    }
    if (this.y < 0) {
      this.y = 0;
    }
    if (this.x + this.popupWidth + 10 > width) {
      this.x = width - this.popupWidth - 10;
    }
    if (this.y + this.popupHeight + 10 > height) {
      this.y = height - this.popupHeight - 10;
    }
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
    setTimeout((function(_this) {
      return function() {
        return _this.myScroll.refresh();
      };
    })(this), 100);
    this.popupWindowHolder.show();
    this.isVisible = true;
    return true;
  };

  PopupWindow.prototype.checkSavedLocation = function() {
    var location;
    location = user.get("PopupLocation_" + this.title, 0);
    if (location !== 0) {
      this.x = location.x;
      return this.y = location.y;
    }
  };

  function PopupWindow(title1, x1, y1) {
    var html, id;
    this.title = title1;
    this.x = x1;
    this.y = y1;
    this.checkSavedLocation = bind(this.checkSavedLocation, this);
    this.resize = bind(this.resize, this);
    this.center = bind(this.center, this);
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
    id = GlobalValueManager.NextGlobalID();
    html = $("<div />", {
      "class": "PopupWindow",
      id: "popup" + id
    });
    this.popupWindowHolder = $(html);
    $("body").append(this.popupWindowHolder);
    this.windowTitle = $("<div />", {
      "class": "title",
      id: "popuptitle" + id,
      dragable: "true"
    }).html(this.title);
    this.popupWindowHolder.append(this.windowTitle);
    this.windowClose = $("<div />", {
      "class": "closebutton",
      id: "windowclose"
    }).html("X");
    this.windowTitle.append(this.windowClose);
    this.windowClose.on("click", (function(_this) {
      return function() {
        return _this.close();
      };
    })(this));
    this.windowScroll = $("<div />", {
      "class": "scrollcontent"
    });
    this.windowWrapper = $("<div />", {
      id: "windowwrapper" + id,
      "class": "scrollable"
    }).append(this.windowScroll);
    this.windowBodyWrapperTop = $("<div />", {
      "class": "windowbody"
    }).css({
      position: "absolute",
      top: this.windowTitle.height() + 2,
      left: 0,
      right: 0,
      bottom: 0
    }).append(this.windowWrapper);
    this.popupWindowHolder.append(this.windowBodyWrapperTop);
    this.myScroll = new IScroll("#windowwrapper" + id, {
      mouseWheel: true,
      scrollbars: true,
      bounce: false,
      resizeScrollbars: false
    });
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
        user.set("PopupLocation_" + _this.title, {
          x: x,
          y: y
        });
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
        _this.popupWindowHolder.css("opacity", "0.95");
        return false;
      };
    })(this));
    this.resize(600, 400);
    this.colCount = 1;
    this.menuItems = {};
    this.menuData = {};
  }

  return PopupWindow;

})();

TableView = (function() {
  TableView.prototype.imgChecked = "<img src='images/checkbox.png' width='16' height='16' alt='Selected' />";

  TableView.prototype.imgNotChecked = "<img src='images/checkbox_no.png' width='16' height='16' alt='Selected' />";

  TableView.prototype.onSetCheckbox = function(checkbox_key, value) {
    return console.log("onSetCheckbox(", checkbox_key, ",", value, ")");
  };

  TableView.prototype.size = function() {
    return this.rowData.length;
  };

  TableView.prototype.numberChecked = function() {
    var i, o, ref, total;
    total = 0;
    ref = this.rowData;
    for (i in ref) {
      o = ref[i];
      if (o.checked) {
        total++;
      }
    }
    return total;
  };

  function TableView(elTableHolder, showCheckboxes) {
    this.elTableHolder = elTableHolder;
    this.showCheckboxes = showCheckboxes;
    this.findRowFromElement = bind(this.findRowFromElement, this);
    this.setFilterFunction = bind(this.setFilterFunction, this);
    this.reset = bind(this.reset, this);
    this.clear = bind(this.clear, this);
    this.addMessageRow = bind(this.addMessageRow, this);
    this.applyFilters = bind(this.applyFilters, this);
    this.filterKeypress = bind(this.filterKeypress, this);
    this.render = bind(this.render, this);
    this.filterFunction = bind(this.filterFunction, this);
    this.onConfigureColumns = bind(this.onConfigureColumns, this);
    this.onContextMenuHeader = bind(this.onContextMenuHeader, this);
    this.setTableCacheName = bind(this.setTableCacheName, this);
    this.setupContextMenuHeader = bind(this.setupContextMenuHeader, this);
    this.setupContextMenu = bind(this.setupContextMenu, this);
    this.internalSetupMouseEvents = bind(this.internalSetupMouseEvents, this);
    this.setupEvents = bind(this.setupEvents, this);
    this.renderCheckable = bind(this.renderCheckable, this);
    this.resetChecked = bind(this.resetChecked, this);
    this.defaultRowClick = bind(this.defaultRowClick, this);
    this.addTable = bind(this.addTable, this);
    this.addJoinTable = bind(this.addJoinTable, this);
    this.numberChecked = bind(this.numberChecked, this);
    this.size = bind(this.size, this);
    this.onSetCheckbox = bind(this.onSetCheckbox, this);
    this.colList = [];
    this.rowData = [];
    this.sort = 0;
    this.showHeaders = true;
    this.showFilters = true;
    this.currentFilters = {};
    this.rowDataElements = {};
    this.contextMenuCallbackFunction = 0;
    this.contextMenuCallSetup = 0;
    if (this.showCheckboxes == null) {
      this.showCheckboxes = false;
    }
    if (!this.elTableHolder[0]) {
      console.log("Error: Table id " + this.elTableHolder + " doesn't exist");
    }
    this.tableConfig = {};
    this.tableConfigDatabase = null;
  }

  TableView.prototype.addJoinTable = function(tableName, columnReduceFunction, sourceField) {
    var c, col, columns, j, len;
    columns = DataMap.getColumnsFromTable(tableName, columnReduceFunction);
    for (j = 0, len = columns.length; j < len; j++) {
      col = columns[j];
      if (col.source !== sourceField) {
        c = new TableViewCol(tableName, col);
        c.joinKey = sourceField;
        c.joinTable = this.primaryTableName;
        this.colList.push(c);
      }
    }
    return true;
  };

  TableView.prototype.addTable = function(tableName, columnReduceFunction, reduceFunction) {
    var c, col, columns, data, j, l, len, len1, row;
    this.primaryTableName = tableName;
    columns = DataMap.getColumnsFromTable(tableName, columnReduceFunction);
    for (j = 0, len = columns.length; j < len; j++) {
      col = columns[j];
      c = new TableViewCol(tableName, col);
      this.colList.push(c);
    }
    data = DataMap.getValuesFromTable(tableName, reduceFunction);
    for (l = 0, len1 = data.length; l < len1; l++) {
      row = data[l];
      if (this.showCheckboxes) {
        row.checkbox_key = tableName + "_" + row.key;
        row.checked = false;
      }
      this.rowData.push(row);
    }
    return true;
  };

  TableView.prototype.defaultRowClick = function(row, e) {
    console.log("DEF ROW CLICK=", row, e);
    return false;
  };

  TableView.prototype.resetChecked = function(bookmarkArray) {
    var i, key, o, ref, x, y;
    ref = this.rowData;
    for (i in ref) {
      o = ref[i];
      o.checked = false;
      for (x in bookmarkArray) {
        y = bookmarkArray[x];
        if (y.key === o.checkbox_key) {
          o.checked = true;
        }
      }
      key = o.key;
      if (o.checked) {
        $("#check_" + this.gid + "_" + key).html(this.imgChecked);
      } else {
        $("#check_" + this.gid + "_" + key).html(this.imgNotChecked);
      }
    }
    return false;
  };

  TableView.prototype.renderCheckable = function(obj) {
    var html, img;
    if (typeof obj.rowOptionAllowCheck !== "undefined" && obj.rowOptionAllowCheck === false) {
      return "<td class='checkable'>&nbsp;</td>";
    }
    img = this.imgNotChecked;
    if (obj.checked) {
      img = this.imgChecked;
    }
    if (this.tableName === "property" && key === window.currentProperty.id) {
      html = "<td class='checkable'> &nbsp; </td>";
    } else {
      html = ("<td class='checkable' id='check_" + this.gid + "_" + obj.key + "'>") + img + "</td>";
    }
    return html;
  };

  TableView.prototype.setupEvents = function(rowCallback, rowMouseover) {
    this.rowCallback = rowCallback;
    this.rowMouseover = rowMouseover;
  };

  TableView.prototype.internalSetupMouseEvents = function() {
    this.elTheTable.find("tr td").bind("click touchbegin", (function(_this) {
      return function(e) {
        var data, defaultResult, key, result;
        e.preventDefault();
        e.stopPropagation();
        data = _this.findRowFromElement(e.target);
        result = false;
        if (!e.target.constructor.toString().match(/Image/)) {
          defaultResult = _this.defaultRowClick(data, e);
          if (defaultResult === false) {
            if (typeof _this.rowCallback === "function") {
              result = _this.rowCallback(data, e);
            }
          } else {
            return false;
          }
        }
        if (result === false) {
          console.log("data=", data);
          if (data.checked != null) {
            data.checked = !data.checked;
            key = data.key;
            if (data.checked) {
              $("#check_" + _this.gid + "_" + key).html(_this.imgChecked);
            } else {
              $("#check_" + _this.gid + "_" + key).html(_this.imgNotChecked);
            }
            _this.onSetCheckbox(data.checkbox_key, data.checked);
          }
        }
        return false;
      };
    })(this));
    this.elTheTable.find("tr td").bind("mouseover", (function(_this) {
      return function(e) {
        var data;
        e.preventDefault();
        e.stopPropagation();
        if (typeof _this.rowMouseover === "function") {
          data = _this.findRowFromElement(e.target);
          _this.rowMouseover(data, "over");
        }
        return false;
      };
    })(this));
    return this.elTheTable.find("tr td").bind("mouseout", (function(_this) {
      return function(e) {
        var data;
        e.preventDefault();
        e.stopPropagation();
        if (typeof _this.rowMouseover === "function") {
          data = _this.findRowFromElement(e.target);
          _this.rowMouseover(data, "out");
        }
        return false;
      };
    })(this));
  };

  TableView.prototype.setupContextMenu = function(contextMenuCallbackFunction) {
    this.contextMenuCallbackFunction = contextMenuCallbackFunction;
    if (this.contextMenuCallSetup === 1) {
      return true;
    }
    this.contextMenuCallSetup = 1;
    this.elTableHolder.on("contextmenu", (function(_this) {
      return function(e) {
        var $target, coords, data;
        e.preventDefault();
        e.stopPropagation();
        coords = GlobalValueManager.GetCoordsFromEvent(e);
        data = _this.findRowFromElement(e.target);
        if (data === null) {
          $target = $(e.target);
          if ($target.is("th")) {
            _this.onContextMenuHeader(coords, $target.text());
            console.log("Click on header:", coords, $target.text());
            return true;
          }
        }
        if (typeof _this.contextMenuCallbackFunction === "function") {
          _this.contextMenuCallbackFunction(coords, data);
        }
        return true;
      };
    })(this));
    return true;
  };

  TableView.prototype.setupContextMenuHeader = function() {
    return this.setupContextMenu(this.contextMenuCallbackFunction);
  };

  TableView.prototype.setTableCacheName = function(tableCacheName) {
    this.tableCacheName = tableCacheName;
  };

  TableView.prototype.onContextMenuHeader = function(coords, column) {
    var popupMenu;
    console.log("COORDS=", coords);
    popupMenu = new PopupMenu("Column: " + column, coords.x - 150, coords.y);
    if (typeof this.tableCacheName !== "undefined" && this.tableCacheName !== null) {
      return popupMenu.addItem("Configure Columns", (function(_this) {
        return function(coords, data) {
          return _this.onConfigureColumns({
            x: coords.x,
            y: coords.y
          });
        };
      })(this));
    }
  };

  TableView.prototype.onConfigureColumns = function(coords) {
    var popup;
    popup = new PopupWindowTableConfiguration("Configure Columns", coords.x - 150, coords.y);
    return popup.show(this);
  };

  TableView.prototype.filterFunction = function(row) {
    return false;
  };

  TableView.prototype.render = function() {
    var col, counter, html, i, j, l, len, len1, len2, r, ref, ref1, ref2, ref3, str, val;
    this.rowDataElements = {};
    if (this.gid == null) {
      this.gid = GlobalValueManager.NextGlobalID();
    }
    html = "<table class='tableview' id='table" + this.gid + "'>";
    if (this.showHeaders) {
      html += "<thead><tr>";
      if (this.showCheckboxes) {
        html += "<th class='checkable'>&nbsp;</th>";
      }
      ref = this.colList;
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        html += i.RenderHeader(i.extraClassName);
      }
      html += "</tr>";
    }
    if (this.showFilters) {
      html += "<thead><tr>";
      if (this.showCheckboxes) {
        html += "<th class='checkable'>&nbsp;</th>";
      }
      ref1 = this.colList;
      for (l = 0, len1 = ref1.length; l < len1; l++) {
        i = ref1[l];
        html += "<td class='dataFilterWrapper'> <input class='dataFilter " + i.col.formatter.name + "' data-path='/" + i.tableName + "/" + i.col.source + "'> </td>";
      }
      html += "</tr>";
    }
    html += "</thead>";
    html += "<tbody id='tbody" + this.gid + "'>";
    if (typeof this.sort === "function") {
      this.rowData.sort(this.sort);
    }
    ref2 = this.rowData;
    for (counter in ref2) {
      i = ref2[counter];
      if (typeof i === "string") {
        html += "<tr class='messageRow'><td class='messageRow' colspan='" + (this.colList.length + 1) + "'";
        html += ">" + i + "</td></tr>";
      } else {
        html += "<tr class='trow' data-id='" + counter + "' ";
        html += ">";
        if (this.showCheckboxes) {
          html += this.renderCheckable(i);
        }
        ref3 = this.colList;
        for (r = 0, len2 = ref3.length; r < len2; r++) {
          col = ref3[r];
          if (col.visible) {
            if (col.joinKey != null) {
              val = DataMap.getDataField(col.joinTable, i.key, col.joinKey);
              str = DataMap.renderField("td", col.tableName, col.col.source, val, col.col.extraClassName);
            } else {
              str = DataMap.renderField("td", col.tableName, col.col.source, i.key, col.col.extraClassName);
            }
            html += str;
          }
        }
        html += "</tr>";
      }
    }
    html += "</tbody></table>";
    this.elTheTable = this.elTableHolder.html(html);
    setTimeout((function(_this) {
      return function() {
        if (typeof setupSimpleTooltips !== "undefined" && setupSimpleTooltips !== null) {
          return setupSimpleTooltips();
        }
      };
    })(this), 1);
    this.contextMenuCallSetup = 0;
    this.internalSetupMouseEvents();
    if (this.showFilters) {
      this.elTheTable.find("input.dataFilter").on("keyup", this.filterKeypress);
    }
    return true;
  };

  TableView.prototype.filterKeypress = function(e) {
    var columnName, parts, tableName;
    parts = $(e.target).attr("data-path").split(/\//);
    tableName = parts[1];
    columnName = parts[2];
    if (this.currentFilters[tableName] == null) {
      this.currentFilters[tableName] = {};
    }
    this.currentFilters[tableName][columnName] = $(e.target).val();
    console.log("VAL=", this.currentFilters[tableName]);
    this.applyFilters();
    return true;
  };

  TableView.prototype.applyFilters = function() {
    var aa, col, counter, filters, i, j, keepRow, len, ref, ref1;
    filters = {};
    ref = this.rowData;
    for (counter in ref) {
      i = ref[counter];
      keepRow = true;
      if (this.currentFilters[i.table]) {
        ref1 = this.colList;
        for (j = 0, len = ref1.length; j < len; j++) {
          col = ref1[j];
          if (this.currentFilters[i.table][col.col.source] == null) {
            continue;
          }
          if (!filters[i.table + col.col.source]) {
            filters[i.table + col.col.source] = new RegExp(this.currentFilters[i.table][col.col.source], "i");
          }
          aa = DataMap.getDataField(i.table, i.key, col.col.source);
          if (!filters[i.table + col.col.source].test(aa)) {
            keepRow = false;
          }
        }
      }
      if (!this.rowDataElements[counter]) {
        this.rowDataElements[counter] = this.elTheTable.find("tr[data-id='" + counter + "']");
      }
      if (keepRow) {
        this.rowDataElements[counter].show();
      } else {
        this.rowDataElements[counter].hide();
      }
    }
    return true;
  };

  TableView.prototype.addMessageRow = function(message) {
    this.rowData.push(message);
    return 0;
  };

  TableView.prototype.clear = function() {
    return this.elTableHolder.html("");
  };

  TableView.prototype.reset = function() {
    this.elTableHolder.html("");
    this.rowData = [];
    this.colList = [];
    return true;
  };

  TableView.prototype.setFilterFunction = function(filterFunction) {
    this.filterFunction = filterFunction;
    return GlobalValueManager.Watch("redrawTables", (function(_this) {
      return function() {
        return _this.render();
      };
    })(this));
  };

  TableView.prototype.findRowFromElement = function(e, stackCount) {
    var data_id, parent;
    if (typeof stackCount === "undefined") {
      stackCount = 0;
    }
    if (stackCount > 4) {
      return null;
    }
    data_id = $(e).attr("data-id");
    if (data_id) {
      return this.rowData[data_id];
    }
    parent = $(e).parent();
    if (parent) {
      return this.findRowFromElement(parent, stackCount + 1);
    }
    return null;
  };

  return TableView;

})();

TableViewCol = (function() {
  function TableViewCol(tableName1, col1) {
    this.tableName = tableName1;
    this.col = col1;
    this.onClickLink = bind(this.onClickLink, this);
    this.RenderHeader = bind(this.RenderHeader, this);
    this.visible = this.col.visible;
    this.width = this.col.width;
    if (this.visible == null) {
      this.visible = true;
    }
    if (this.width == null) {
      this.width = "";
    }
  }

  TableViewCol.prototype.RenderHeader = function(extraClassName) {
    var html;
    if (this.visible === false) {
      return "";
    }
    html = "<th style='";
    if (this.width) {
      html += "width: " + this.width + ";";
    }
    html += "'";
    if ((this.col.extraClassName != null) && this.col.extraClassName.length > 0) {
      html += "class='" + this.col.extraClassName + "'";
    }
    if ((this.col.tooltip != null) && this.col.tooltip.length > 0) {
      html += " tooltip='simple' data-title='" + this.col.tooltip + "'";
    }
    html += ">";
    html += this.col.name;
    html += "</th>";
    return html;
  };

  TableViewCol.prototype.onClickLink = function() {
    return window.open(this.link, "showWindow", "height=800,width=1200,menubar=no,toolbar=no,location=no,status=no,resizable=yes");
  };

  return TableViewCol;

})();

PopupWindowTableConfiguration = (function(superClass) {
  extend(PopupWindowTableConfiguration, superClass);

  function PopupWindowTableConfiguration() {
    this.show = bind(this.show, this);
    return PopupWindowTableConfiguration.__super__.constructor.apply(this, arguments);
  }

  PopupWindowTableConfiguration.prototype.show = function(refTable) {
    var col, columns, j, len, ref;
    this.resize(900, 700);
    this.tableConfig = new TableView(this.windowScroll, refTable.tableCacheName, "name");
    this.tableConfig.tableConfigDatabase = refTable.tableCacheName;
    console.log("tableConfigDatabase=", this.tableConfig.tableConfigDatabase);
    columns = [];
    columns.push({
      name: "Title",
      source: "name",
      type: "text",
      width: "110px"
    });
    columns.push({
      name: "Additional Information",
      source: "tooltip",
      type: "text"
    });
    DataMap.setDataTypes("colConfig", columns);
    ref = refTable.colList;
    for (j = 0, len = ref.length; j < len; j++) {
      col = ref[j];
      console.log("COL=", col);
    }
    this.tableConfig.addTable("colConfig");
    this.tableConfig.render();
    this.tableConfig.onSetCheckbox = (function(_this) {
      return function(checkbox_key, value) {
        console.log("HERE", checkbox_key, value);
        return user.tableConfigSetColumnVisible(refTable.tableCacheName, checkbox_key, value);
      };
    })(this);
    return this.open();
  };

  return PopupWindowTableConfiguration;

})(PopupWindow);

TableViewDetailed = (function(superClass) {
  extend(TableViewDetailed, superClass);

  function TableViewDetailed() {
    this.realRender = bind(this.realRender, this);
    return TableViewDetailed.__super__.constructor.apply(this, arguments);
  }

  TableViewDetailed.prototype.leftWidth = 140;

  TableViewDetailed.prototype.realRender = function() {
    var col, counter, html, i, j, l, len, len1, ref, ref1;
    if (typeof this.gid === "undefined") {
      this.gid = GlobalValueManager.NextGlobalID();
    }
    this.processTableConfig();
    html = "<table class='detailview' id='table" + this.gid + "'>";
    html += "<tbody id='tbody" + this.gid + "'>";
    counter = 0;
    if (typeof this.sort === "function") {
      this.rowData.sort(this.sort);
    }
    ref = this.colList;
    for (j = 0, len = ref.length; j < len; j++) {
      col = ref[j];
      col.styleFormat = "";
      col.width = "";
      if (!col.visible) {
        continue;
      }
      html += "<tr class='trow' data-id='" + counter + "' ";
      html += ">";
      if (this.keyColumn && this.tableName) {
        html += this.renderCheckable(i);
      }
      if (col.visible !== false) {
        html += "<th style='text-align: right; width: " + this.leftWidth + "px; '> ";
        html += col.title;
        html += "</th>";
      }
      ref1 = this.rowData;
      for (l = 0, len1 = ref1.length; l < len1; l++) {
        i = ref1[l];
        if (this.basePath !== 0) {
          col.setBasePath(this.basePath + "/" + i.id);
        }
        col.formatter.styleFormat = "";
        html += col.Render(counter, i);
      }
      html += "</tr>";
    }
    html += "</tbody></table>";
    this.elTheTable = this.elTableHolder.html(html);
    setTimeout((function(_this) {
      return function() {
        globalResizeScrollable();
        return setupSimpleTooltips();
      };
    })(this), 100);
    this.contextMenuCallSetup = 0;
    this.setupContextMenuHeader();
    this.internalSetupMouseEvents();
    return true;
  };

  return TableViewDetailed;

})(TableView);

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

AddressNormalizer = (function() {
  AddressNormalizer.prototype.lat = null;

  AddressNormalizer.prototype.lon = null;

  AddressNormalizer.prototype.tile_x = null;

  AddressNormalizer.prototype.tile_y = null;

  AddressNormalizer.prototype.house_number = null;

  AddressNormalizer.prototype.street_number = null;

  AddressNormalizer.prototype.street_prefix = null;

  AddressNormalizer.prototype.street_direction = null;

  AddressNormalizer.prototype.street_suffix = null;

  AddressNormalizer.prototype.unit_number = null;

  AddressNormalizer.prototype.city = null;

  AddressNormalizer.prototype.state = null;

  AddressNormalizer.prototype.zipcode = null;

  AddressNormalizer.prototype.zipfour = null;

  AddressNormalizer.prototype.seperator = ', ';

  function AddressNormalizer(options) {
    this.extractZip = bind(this.extractZip, this);
    this.getAddressPart = bind(this.getAddressPart, this);
    this.fixTitleCase = bind(this.fixTitleCase, this);
    this.getDisplayAddress = bind(this.getDisplayAddress, this);
    if (options.city != null) {
      this.city = this.fixTitleCase(options.city);
    }
    if (options.lat != null) {
      this.lat = options.lat;
    }
    if (options.lon != null) {
      this.lon = options.lon;
    }
    if (options.tile_x != null) {
      this.tile_x = options.tile_x;
    }
    if (options.tile_y != null) {
      this.tile_y = options.tile_y;
    }
    if (options.street_number != null) {
      this.street_number = options.street_number;
    }
    if (options.street_prefix != null) {
      this.street_prefix = options.street_prefix;
    }
    if (options.street_direction != null) {
      this.street_direction = options.street_direction;
    }
    if (options.street_suffix != null) {
      this.street_suffix = options.street_suffix;
    }
    if (options.unit_number != null) {
      this.unit_number = options.unit_number;
    }
    if (options.state != null) {
      this.state = options.state;
    }
    if (options.zipcode != null) {
      this.zipcode = options.zipcode;
    }
    if (options.zipfour != null) {
      this.zipfour = options.zipfour;
    }
  }

  AddressNormalizer.prototype.getDisplayAddress = function() {
    return (this.getAddressPart()) + ", " + (this.unit_number ? this.unit_number + ', ' : '') + " " + (this.city ? this.city + ', ' : '') + " " + (this.state ? this.state + ', ' : '') + " " + (this.zipcode ? this.extractZip() : '');
  };

  AddressNormalizer.prototype.fixTitleCase = function(strTitleText) {
    return strTitleText.replace(/\w\S*/g, function(txt) {
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
  };

  AddressNormalizer.prototype.getAddressPart = function() {
    var suffixParser;
    suffixParser = new StreetSuffixParser();
    return (this.street_number ? this.street_number : "") + " " + (this.street_prefix ? this.street_prefix : "") + " " + (this.street_direction ? this.street_direction : "") + " " + (this.street_suffix ? suffixParser.getSuffix(this.street_suffix) : '');
  };

  AddressNormalizer.prototype.extractZip = function() {
    var zip;
    if (/^\d{5}-\d{4}$/.test(this.zipcode)) {
      return zip = this.zipcode.split('-')[0];
    } else {
      return zip = this.zipcode;
    }
  };

  return AddressNormalizer;

})();

try {
  GlobalAddressNormalizer = new AddressNormalizer({
    city: 'sample'
  });
} catch (_error) {
  e = _error;
  console.log("Exception while registering global Address Formatter:", e);
}

AddressParser = (function() {
  AddressParser.prototype.address = null;

  AddressParser.prototype.seperator = ', ';

  AddressParser.prototype.response = {};

  AddressParser.prototype.states = {
    'Alabama': 'AL',
    'Alaska': 'AK',
    'American Samoa': 'AS',
    'Arizona': 'AZ',
    'Arkansas': 'AR',
    'California': 'CA',
    'Colorado': 'CO',
    'Connecticut': 'CT',
    'Delaware': 'DE',
    'District Of Columbia': 'DC',
    'Federated States Of Micronesia': 'FM',
    'Florida': 'FL',
    'Georgia': 'GA',
    'Guam': 'GU',
    'Hawaii': 'HI',
    'Idaho': 'ID',
    'Illinois': 'IL',
    'Indiana': 'IN',
    'Iowa': 'IA',
    'Kansas': 'KS',
    'Kentucky': 'KY',
    'Louisiana': 'LA',
    'Maine': 'ME',
    'Marshall Islands': 'MH',
    'Maryland': 'MD',
    'Massachusetts': 'MA',
    'Michigan': 'MI',
    'Minnesota': 'MN',
    'Mississippi': 'MS',
    'Missouri': 'MO',
    'Montana': 'MT',
    'Nebraska': 'NE',
    'Nevada': 'NV',
    'New Hampshire': 'NH',
    'New Jersey': 'NJ',
    'New Mexico': 'NM',
    'New York': 'NY',
    'North Carolina': 'NC',
    'North Dakota': 'ND',
    'Northern Mariana Islands': 'MP',
    'Ohio': 'OH',
    'Oklahoma': 'OK',
    'Oregon': 'OR',
    'Palau': 'PW',
    'Pennsylvania': 'PA',
    'Puerto Rico': 'PR',
    'Rhode Island': 'RI',
    'South Carolina': 'SC',
    'South Dakota': 'SD',
    'Tennessee': 'TN',
    'Texas': 'TX',
    'Utah': 'UT',
    'Vermont': 'VT',
    'Virgin Islands': 'VI',
    'Virginia': 'VA',
    'Washington': 'WA',
    'West Virginia': 'WV',
    'Wisconsin': 'WI',
    'Wyoming': 'WY'
  };

  function AddressParser(address) {
    if (!address || !AddressParser.check(address)) {
      throw 'invalid address supplied';
    }
    this.address = address;
    this.response = {
      warnings: []
    };
  }

  AddressParser.prototype.parse = function() {
    this.parts = this.address.split(this.seperator);
    this.processStreet($.trim(this.parts[0]));
    this.response.city = $.trim(this.parts[1]).length ? $.trim(this.parts[1]) : void 0;
    this.response.zipcode = $.trim(this.parts[3]).length ? $.trim(this.parts[3]) : void 0;
    this.response.state = this.getStateShortName($.trim(this.parts[2]).length ? $.trim(this.parts[2]) : void 0);
    this.verifyCity();
    this.getZipCode();
    if (!this.response.warnings.length) {
      delete this.response.warnings;
    }
    return this.response;
  };

  AddressParser.prototype.processStreet = function(streetString) {
    this.matches = /^(\d+\s)?(.+)$/.exec(streetString);
    this.response.street_number = this.matches[1];
    this.streetParts = this.matches[2].split(" ");
    this.response.street_prefix = this.streetParts[0];
    if (this.streetParts.length >= 3) {
      this.response.street_direction = this.streetParts[1].length ? this.streetParts[1] : void 0;
      this.suffixString = this.streetParts[2];
    } else if (this.streetParts.length === 2) {
      this.suffixString = this.streetParts[1];
    } else {
      this.suffixString = null;
    }
    if (this.suffixString) {
      this.suffixParser = new StreetSuffixParser();
      this.suffix = this.suffixParser.getSuffix(this.suffixString);
    }
    return this.response.street_suffix = this.suffix;
  };

  AddressParser.prototype.getStateShortName = function(state) {
    if (state && state.length > 2) {
      if (this.states[state]) {
        return this.states[state];
      } else {
        this.response.warnings.push("State Abbreviation not found");
        return state;
      }
    } else {
      return state;
    }
  };

  AddressParser.prototype.verifyCity = function() {
    var _city;
    if (this.response.zipcode && this.response.city) {
      _city = DataMap.getDataField('zipcode', this.response.zipcode, 'city');
      if (_city !== this.response.city) {
        return this.response.warnings.push("Invalid City " + this.response.city + " != " + _city);
      }
    }
  };

  AddressParser.prototype.getZipCode = function() {
    var _zipObj;
    if (!this.response.zipcode && (this.response.city || this.response.state)) {
      _zipObj = DataMap.getValuesFromTable('zipcode', (function(_this) {
        return function(obj) {
          return obj.city === _this.response.city || obj.state === _this.response.state;
        };
      })(this)).pop();
      if (_zipObj.hasOwnProperty('key')) {
        if (!this.response.state) {
          this.response.state = DataMap.getDataMap().data['zipcode'][_zipObj.key].state;
        }
        return this.response.zipcode = _zipObj.key;
      }
    }
  };

  AddressParser.check = function(address) {
    return /^(\d+\s)?[\w\s'.,]+(\d{5}|\d{5}-\d{4})?$/.test(address);
  };

  return AddressParser;

})();

try {
  GlobalAddressParser = new AddressParser('2467 Bearded Iris Lane, High Point, North Carolina, 27265');
} catch (_error) {
  e = _error;
  console.log("Exception while registering global Address Parser:", e);
}

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
    if (date === null) {
      return null;
    }
    if (typeof date !== "string") {
      return null;
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

  GlobalValueManager.Ucwords = function(str) {
    return (str + '').replace(/^([a-z\u00E0-\u00FC])|\s+([a-z\u00E0-\u00FC])/g, function($1) {
      return $1.toUpperCase();
    });
  };

  GlobalValueManager.Trigger = function(eventName, dataObject) {
    $("body").trigger(eventName, dataObject);
    return true;
  };

  GlobalValueManager.Watch = function(eventName, delegate) {
    $("body").on(eventName, delegate);
    return true;
  };

  return GlobalValueManager;

})();

StreetSuffixParser = (function() {
  function StreetSuffixParser() {
    this.getSuffix = bind(this.getSuffix, this);
  }

  StreetSuffixParser.prototype.suffixes = {
    ALY: ['ALLEE', 'ALLEY', 'ALLY', 'ALY'],
    ANX: ['ANEX', 'ANNEX', 'ANNX', 'ANX'],
    ARC: ['ARC', 'ARCADE'],
    AVE: ['AVE', 'AVEN', 'AV', 'AVENU', 'AVENUE', 'AVN', 'AVNUE'],
    BYU: ['BAYOO', 'BAYOU'],
    BCH: ['BCH', 'BEACH'],
    BND: ['BEND', 'BND'],
    BLF: ['BLF', 'BLUFF', 'BLUF'],
    BLFS: ['BLUFFS'],
    BTM: ['BOT', 'BTM', 'BOTTOM', 'BOTTM'],
    BLVD: ['BLVD', 'BOUL', 'BOULEVARD', 'BOULV'],
    BR: ['BR', 'BRNCH', 'BRANCH'],
    BRG: ['BRDGE', 'BRIDGE', 'BRG'],
    BRK: ['BROOK', 'BRK'],
    BRKS: ['BROOKS'],
    BG: ['BURG'],
    BGS: ['BURGS'],
    BYP: ['BYP', 'BYPA', 'BYPAS', 'BYPASS', 'BYPS'],
    CP: ['CAMP', 'CP', 'CMP'],
    CYN: ['CANYN', 'CANYON', 'CNYN'],
    CPE: ['CAPE', 'CPE'],
    CSWY: ['CAUSEWAY', 'CAUSWA', 'CSWY'],
    CTR: ['CEN', 'CENT', 'CENTER', 'CENTR', 'CENTRE', 'CNTER', 'CNTR', 'CTR'],
    CTRS: ['CENTERS'],
    CIR: ['CIR', 'CIRC', 'CIRCL', 'CIRCLE', 'CRCL', 'CRCLE'],
    CIRS: ['CIRCLES'],
    CLF: ['CLF', 'CLIFF'],
    CLFS: ['CLFS', 'CLIFFS'],
    CLB: ['CLUB', 'CLB'],
    CMN: ['COMMON'],
    CMNS: ['COMMONS'],
    COR: ['COR', 'CORNOR'],
    CORS: ['CORS', 'CORNORS'],
    CRSE: ['CRSE', 'COURSE'],
    CT: ['CT', 'COURT'],
    CTS: ['CTS', 'COURTS'],
    CV: ['COVE', 'CV'],
    CVS: ['COVES'],
    CRK: ['CREEK', 'CRK'],
    CRES: ['CRESCENT', 'CRES', 'CRSENT', 'CRSNT'],
    CRST: ['CREST'],
    XING: ['CROSSING', 'CRSSNG', 'XING'],
    XRD: ['CROSSROAD'],
    XRDS: ['CROSSROADS'],
    CURV: ['CURVE'],
    DL: ['DALE', 'DL'],
    DM: ['DAM', 'DM'],
    DV: ['DIVIDE', 'DIV', 'DV', 'DVD'],
    DR: ['DRIV', 'DR', 'DRIVE', 'DRV'],
    DRS: ['DRIVES'],
    EST: ['ESTATE', 'EST'],
    ESTS: ['ESTATES', 'ESTS'],
    EXPY: ['EXPRESS', 'EXP', 'EXPR', 'EXPRESSWAY', 'EXPW', 'EXPY'],
    EXT: ['EXTENSION', 'EXT', 'EXTN', 'EXTNSN'],
    EXTS: ['EXTS'],
    FALL: ['FALL'],
    FLS: ['FALLS', 'FLS'],
    FRY: ['FERRY', 'FRRY', 'FRY'],
    FLD: ['FIELD', 'FLD'],
    FLDS: ['FIELDS', 'FLDS'],
    FLT: ['FLT', 'FLAT'],
    FLTS: ['FLATS', 'FLTS'],
    FRD: ['FORD', 'FRD'],
    FRDS: ['FORDS'],
    FRST: ['FOREST', 'FORESTS', 'FRST'],
    FRG: ['FORG', 'FORGE', 'FRG'],
    FRGS: ['FORGES'],
    FRK: ['FORK', 'FRK'],
    FRKS: ['FORKS', 'FRKS'],
    FT: ['FORT', 'FT', 'FRT'],
    FWY: ['FREEWAY', 'FREEWY', 'FRWAY', 'FRWY', 'FWY'],
    GDN: ['GARDEN', 'GARDN', 'GRDEN', 'GRDN'],
    GDNS: ['GARDENS', 'GDNS', 'GRDNS'],
    GTWY: ['GATEWAY', 'GATEWY', 'GATWAY', 'GTWAY', 'GTWY'],
    GLN: ['GLEN', 'GLN'],
    GLNS: ['GLENS'],
    GRN: ['GRN', 'GREEN'],
    GRNS: ['GREENS'],
    GRV: ['GROV', 'GROVE', 'GRV'],
    GRVS: ['GROVES'],
    HBR: ['HARB', 'HARBOR', 'HARBR', 'HRBOR', 'HBR'],
    HBRS: ['HARBORS'],
    HVN: ['HAVEN', 'HVN'],
    HTS: ['HT', 'HTS'],
    HWY: ['HIGHWAY', 'HIGHWY', 'HIWAY', 'HIWY', 'HWAY', 'HWY'],
    HL: ['HL', 'HILL'],
    HLS: ['HLS', 'HILLS'],
    HOLW: ['HLLW', 'HOLLOW', 'HOLLOWS', 'HOLW', 'HOLWS'],
    INLT: ['INLT'],
    IS: ['ISLAND', 'IS', 'ISLND'],
    ISS: ['ISLANDS', 'ISS', 'ISLNDS'],
    ISLE: ['ISLE', 'ISLES'],
    JCT: ['JCTION', 'JCT', 'JCTN', 'JUNCTION', 'JUNCTN', 'JUNCTON'],
    JCTS: ['JCTNS', 'JCTS', 'JUNCTIONS'],
    KY: ['KEY', 'KY'],
    KYS: ['KEYS', 'KYS'],
    KNL: ['KNL', 'KNOL', 'KNOLL'],
    KNLS: ['KNLS', 'KNOLLS'],
    LK: ['LAKE', 'LK'],
    LKS: ['LAKES', 'LKS'],
    LAND: ['LAND'],
    LNDG: ['LANDING', 'LNDNG', 'LNDG'],
    LN: ['LN', 'LANE'],
    LGT: ['LGN', 'LIGHT'],
    LGTS: ['LIGTHS'],
    LF: ['LF', 'LOAF'],
    LCK: ['LCK', 'LOCK'],
    LCKS: ['LCKS', 'LOCKS'],
    LDG: ['LDG', 'LDGE', 'LODG', 'LODGE'],
    LOOP: ['LOOP', 'LOOPS'],
    MALL: ['MALL'],
    MNR: ['MANOR', 'MNR'],
    MNRS: ['MANORS', 'MNRS'],
    MDW: ['MEADOW'],
    MDWS: ['MDWS', 'MDW', 'MEADOWS', 'MEDOWS'],
    MEWS: ['MEWS'],
    ML: ['MILL'],
    MLS: ['MILLS'],
    MSN: ['MISSN', 'MSSN'],
    MTWY: ['MOTORWAY'],
    MT: ['MNT', 'MT', 'MOUNT'],
    MTN: ['MNTAIN', 'MNTN', 'MOUNTAIN', 'MOUNTIN', 'MTIN', 'MTN'],
    MTNS: ['MOUNTAINS', 'MNTNS'],
    NCK: ['NECK', 'NCK'],
    ORCH: ['ORCH', 'ORCHARD', 'ORCHRD'],
    OVAL: ['OVAL', 'OVL'],
    OPAS: ['OVERPASS'],
    PARK: ['PARK', 'PRK'],
    PARK: ['PARKS'],
    PKWY: ['PARKWAY', 'PARKWY', 'PKWAY', 'PKWY', 'PKY'],
    PKWYS: ['PARKWAYS', 'PKWYS'],
    PASS: ['PASS'],
    PSGE: ['PASSAGE'],
    PATH: ['PATH', 'PATHS'],
    PIKE: ['PIKE', 'PIKES'],
    PNE: ['PINE'],
    PNES: ['PINES', 'PNES'],
    PL: ['PL'],
    PLN: ['PLAIN', 'PLN'],
    PLNS: ['PLAINS', 'PLNS'],
    PLZ: ['PLAZA', 'PLZ', 'PLZA'],
    PT: ['PT', 'POINT'],
    PTS: ['PTS', 'POINTS'],
    PRT: ['PRT', 'PORT'],
    PRTS: ['PRTS', 'PORTS'],
    PR: ['PRAIRIE', 'PR', 'PRR'],
    RADL: ['RADL', 'RADIAL', 'RAD', 'RADIEL'],
    RAMP: ['RAMP'],
    RNCH: ['RANCH', 'RANCHES', 'RNCH', 'RNCHS'],
    RPD: ['RAPID', 'RPD'],
    RPDS: ['RAPIDS', 'RPDS'],
    RST: ['REST', 'RST'],
    RDG: ['RDG', 'RDGE', 'RIDGE'],
    RDGS: ['RIDGES', 'RDGS'],
    RIV: ['RIV', 'RIVER', 'RVR', 'RIVR'],
    RD: ['ROAD', 'RD'],
    RDS: ['ROADS', 'RDS'],
    RTE: ['ROUTE'],
    ROW: ['ROW'],
    RUE: ['RUE'],
    RUN: ['RUN'],
    SHL: ['SHOAL', 'SHL'],
    SHLS: ['SHOALS', 'SHLS'],
    SHR: ['SHOAR', 'SHORE', 'SHR'],
    SHRS: ['SHOARS', 'SHORES', 'SHRS'],
    SKWY: ['SKYWAY'],
    SPG: ['SPNG', 'SPG', 'SPRING', 'SPRNG'],
    SPGS: ['SPNGS', 'SPGS', 'SPRINGS', 'SPRNGS'],
    SPUR: ['SPUR'],
    SPURS: ['SPURS'],
    SQ: ['SQ', 'SQR', 'SQRE', 'SQU', 'SQUARE'],
    SQS: ['SQRS', 'SQUARES'],
    STA: ['STATION', 'STA', 'STATN', 'STN'],
    STRA: ['STRA', 'STRAV', 'STRAVEN', 'STRAVENUE', 'STRAVN', 'STRVN', 'STRVNUE'],
    STRM: ['STREAM', 'STRM', 'STREME'],
    ST: ['STREET', 'STRT', 'ST', 'STR'],
    STS: ['STREETS'],
    SMT: ['SMT', 'SUMIT', 'SUMITT', 'SUMMIT'],
    TER: ['TER', 'TERR', 'TERRACE'],
    TRWY: ['THROUGHWAY'],
    TRCE: ['TRACE', 'TRACES', 'TRCE'],
    TRAK: ['TRACK', 'TRACKS', 'TRAK', 'TRKS', 'TRK'],
    TRFY: ['TRAFFICWAY'],
    TRL: ['TRAIL', 'TRAILS', 'TRL', 'TRLS'],
    TRLR: ['TRAILER', 'TRLR', 'TRLRS'],
    TUNL: ['TUNEL', 'TUNL', 'TUNLS', 'TUNNEL', 'TUNNELS', 'TUNNL'],
    TPKE: ['TRNPK', 'TURNPIKE', 'TURNPK'],
    UPAS: ['UNDERPASS'],
    UN: ['UN', 'UNION'],
    UNS: ['UNIONS'],
    VLY: ['VALLEY', 'VALLY', 'VLLY', 'VLY'],
    VLYS: ['VALLEYS', 'VLYS'],
    VIA: ['VDCT', 'VIA', 'VIADCT', 'VIADUCT'],
    VW: ['VIEW', 'VW'],
    VWS: ['VIEWS', 'VWS'],
    VLG: ['VILL', 'VILLAG', 'VILLAGE', 'VILLG', 'VILLIAGE', 'VLG'],
    VLGS: ['VILLAGES', 'VLGS'],
    VL: ['VILLE', 'VL'],
    VIS: ['VIS', 'VIST', 'VISTA', 'VST', 'VSTA'],
    WALK: ['WALK'],
    WALK: ['WALKS'],
    WALL: ['WALL'],
    WAY: ['WY', 'WAY'],
    WAYS: ['WAYS'],
    WL: ['WELL'],
    WLS: ['WELLS', 'WLS']
  };

  StreetSuffixParser.prototype.getSuffix = function(name) {
    var keys, suffix;
    suffix = null;
    keys = Object.keys(this.suffixes);
    keys.forEach((function(_this) {
      return function(key) {
        return _this.suffixes[key].forEach(function(f) {
          if (f.toLowerCase() === name.toLowerCase()) {
            return suffix = key;
          }
        });
      };
    })(this));
    return suffix;
  };

  return StreetSuffixParser;

})();

try {
  GlobalStreetSuffixParser = new StreetSuffixParser();
} catch (_error) {
  e = _error;
  console.log("Exception while registering global Address Formatter:", e);
}

//# sourceMappingURL=ninja.js.map
