(function () {
  function setLayoutVars() {
    var headerEl =
      document.querySelector("header") ||
      document.querySelector("#header") ||
      document.querySelector(".header") ||
      null;

    var pageTop = document.getElementById("pageTop");
    var headerH = headerEl ? headerEl.getBoundingClientRect().height : 0;
    var topH = pageTop ? pageTop.getBoundingClientRect().height : 56;

    document.documentElement.style.setProperty("--header-h", Math.ceil(headerH) + "px");
    document.documentElement.style.setProperty("--top-h", Math.ceil(topH) + "px");
  }

  if (window.addEventListener) {
    window.addEventListener("load", setLayoutVars);
    window.addEventListener("resize", setLayoutVars);
  }

  // ✅ 최종 요구사항 반영
  // 온도/습도/악취: high/low/realertMin
  // 피플: high(명)
  // 페이퍼타올/액체비누: threshold(%) 1개
  var DEFAULTS = {
    temp:   { high: 30.0, low: 15.0, realertMin: 10, alert: true },
    hum:    { high: 80,   low: 20,   realertMin: 10, alert: true },
    nh3:    { high: 1.0,  low: 0.5,  realertMin: 10, alert: true },

    people: { high: 25, alert: true },
    towel:  { threshold: 20, alert: true },
    soap:   { threshold: 20, alert: true }
  };

  var STORAGE_KEY = "smartRestroom.thresholds.v3";

  function $(id) { return document.getElementById(id); }

  function showToast(msg) {
    var t = $("toast");
    if (!t) return;
    t.textContent = msg || "완료되었습니다.";
    t.classList.add("show");
    setTimeout(function () { t.classList.remove("show"); }, 1300);
  }

  function setSwitch(key, on) {
    var sw = document.querySelector('.switch[data-toggle="' + key + '"]');
    if (!sw) return;
    if (on) sw.classList.add("on");
    else sw.classList.remove("on");
    sw.setAttribute("aria-checked", on ? "true" : "false");
  }

  function readSwitch(key) {
    var sw = document.querySelector('.switch[data-toggle="' + key + '"]');
    return !!(sw && sw.classList.contains("on"));
  }

  function toggleSwitchEl(sw) {
    if (!sw) return;
    sw.classList.toggle("on");
    sw.setAttribute("aria-checked", sw.classList.contains("on") ? "true" : "false");
  }

  function bindSwitches() {
    var switches = document.querySelectorAll(".switch[data-toggle]");
    for (var i = 0; i < switches.length; i++) {
      (function (sw) {
        sw.addEventListener("click", function () {
          toggleSwitchEl(sw);
        });
        sw.addEventListener("keydown", function (e) {
          var key = e.key || e.keyCode;
          if (key === "Enter" || key === " " || key === 13 || key === 32) {
            e.preventDefault();
            toggleSwitchEl(sw);
          }
        });
      })(switches[i]);
    }
  }

  function safeNumber(value, fallback) {
    var n = parseFloat(value);
    return isNaN(n) ? fallback : n;
  }

  function clamp(n, min, max) {
    if (typeof min === "number" && n < min) return min;
    if (typeof max === "number" && n > max) return max;
    return n;
  }

  function getFormData() {
    var data = {
      temp: {
        high: safeNumber($("temp_high").value, DEFAULTS.temp.high),
        low:  safeNumber($("temp_low").value,  DEFAULTS.temp.low),
        realertMin: safeNumber($("temp_realert_min").value, DEFAULTS.temp.realertMin),
        alert: readSwitch("temp")
      },
      hum: {
        high: safeNumber($("hum_high").value, DEFAULTS.hum.high),
        low:  safeNumber($("hum_low").value,  DEFAULTS.hum.low),
        realertMin: safeNumber($("hum_realert_min").value, DEFAULTS.hum.realertMin),
        alert: readSwitch("hum")
      },
      nh3: {
        high: safeNumber($("nh3_high").value, DEFAULTS.nh3.high),
        low:  safeNumber($("nh3_low").value,  DEFAULTS.nh3.low),
        realertMin: safeNumber($("nh3_realert_min").value, DEFAULTS.nh3.realertMin),
        alert: readSwitch("nh3")
      },
      people: {
        high: safeNumber($("people_high").value, DEFAULTS.people.high),
        alert: readSwitch("people")
      },
      towel: {
        threshold: safeNumber($("towel_threshold").value, DEFAULTS.towel.threshold),
        alert: readSwitch("towel")
      },
      soap: {
        threshold: safeNumber($("soap_threshold").value, DEFAULTS.soap.threshold),
        alert: readSwitch("soap")
      }
    };

    // 검증/보정
    data.hum.high = clamp(data.hum.high, 0, 100);
    data.hum.low  = clamp(data.hum.low,  0, 100);

    data.temp.realertMin = clamp(data.temp.realertMin, 1, null);
    data.hum.realertMin  = clamp(data.hum.realertMin,  1, null);
    data.nh3.realertMin  = clamp(data.nh3.realertMin,  1, null);

    data.nh3.high = clamp(data.nh3.high, 0, null);
    data.nh3.low  = clamp(data.nh3.low,  0, null);

    data.people.high = clamp(data.people.high, 0, null);

    data.towel.threshold = clamp(data.towel.threshold, 0, 100);
    data.soap.threshold  = clamp(data.soap.threshold,  0, 100);

    return data;
  }

  function setFormData(data) {
    data = data || DEFAULTS;

    // temp
    $("temp_high").value = (data.temp && data.temp.high != null) ? data.temp.high : DEFAULTS.temp.high;
    $("temp_low").value  = (data.temp && data.temp.low  != null) ? data.temp.low  : DEFAULTS.temp.low;
    $("temp_realert_min").value = (data.temp && data.temp.realertMin != null) ? data.temp.realertMin : DEFAULTS.temp.realertMin;
    setSwitch("temp", !(data.temp && data.temp.alert === false));

    // hum
    $("hum_high").value = (data.hum && data.hum.high != null) ? data.hum.high : DEFAULTS.hum.high;
    $("hum_low").value  = (data.hum && data.hum.low  != null) ? data.hum.low  : DEFAULTS.hum.low;
    $("hum_realert_min").value = (data.hum && data.hum.realertMin != null) ? data.hum.realertMin : DEFAULTS.hum.realertMin;
    setSwitch("hum", !(data.hum && data.hum.alert === false));

    // nh3
    $("nh3_high").value = (data.nh3 && data.nh3.high != null) ? data.nh3.high : DEFAULTS.nh3.high;
    $("nh3_low").value  = (data.nh3 && data.nh3.low  != null) ? data.nh3.low  : DEFAULTS.nh3.low;
    $("nh3_realert_min").value = (data.nh3 && data.nh3.realertMin != null) ? data.nh3.realertMin : DEFAULTS.nh3.realertMin;
    setSwitch("nh3", !(data.nh3 && data.nh3.alert === false));

    // people
    $("people_high").value = (data.people && data.people.high != null) ? data.people.high : DEFAULTS.people.high;
    setSwitch("people", !(data.people && data.people.alert === false));

    // towel/soap
    $("towel_threshold").value = (data.towel && data.towel.threshold != null) ? data.towel.threshold : DEFAULTS.towel.threshold;
    setSwitch("towel", !(data.towel && data.towel.alert === false));

    $("soap_threshold").value = (data.soap && data.soap.threshold != null) ? data.soap.threshold : DEFAULTS.soap.threshold;
    setSwitch("soap", !(data.soap && data.soap.alert === false));
  }

  function loadFromStorage() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return null;
      return JSON.parse(raw);
    } catch (e) {
      return null;
    }
  }

  function saveToStorage(data) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
      return true;
    } catch (e) {
      return false;
    }
  }

  // 서버 저장 API가 있으면 여기만 교체
  function saveToServer(data) {
    return Promise.resolve(true);
  }

  function onSave() {
    var data = getFormData();

    var ok = saveToStorage(data);
    if (!ok) {
      showToast("저장에 실패했습니다.");
      return;
    }

    saveToServer(data).then(function () {
      showToast("저장되었습니다.");
    }).catch(function () {
      showToast("저장에 실패했습니다.");
    });
  }

  function onReset() {
    setFormData(DEFAULTS);
    saveToStorage(DEFAULTS);
    showToast("기본값으로 초기화했습니다.");
  }

  function bindButtons() {
    var btnSave = $("btnSave");
    var btnReset = $("btnReset");
    if (btnSave) btnSave.addEventListener("click", onSave);
    if (btnReset) btnReset.addEventListener("click", onReset);
  }

  function init() {
    bindSwitches();
    bindButtons();

    var saved = loadFromStorage();
    if (saved) setFormData(saved);
    else setFormData(DEFAULTS);

    setLayoutVars();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
