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

  // 초기 설정값
  var DEFAULTS = {
    temp:   { high: 27.0, low: 18.0, realertMin: 10, alert: true },
    hum:    { high: 60,   low: 40,   realertMin: 10, alert: true },
    nh3:    { warning: 5.0,  critical: 10.0,  realertMin: 10, alert: true },
    people: { high: 40, alert: true },
    towel:  { threshold: 10, alert: true },
    soap:   { threshold: 10, alert: true }
  };

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
        warning:  safeNumber($("nh3_high").value, DEFAULTS.nh3.warning),
        critical: safeNumber($("nh3_low").value,  DEFAULTS.nh3.critical),
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
    
    data.hum.high = clamp(data.hum.high, 0, 100);
    data.towel.threshold = clamp(data.towel.threshold, 0, 100);
    return data;
  }

  function setFormData(data) {
    data = data || DEFAULTS;

    $("temp_high").value = Number(data.temp.high).toFixed(1);
    $("temp_low").value  = Number(data.temp.low).toFixed(1);
    $("temp_realert_min").value = data.temp.realertMin;
    setSwitch("temp", data.temp.alert);

    $("nh3_high").value = Number(data.nh3.warning).toFixed(1);
    $("nh3_low").value  = Number(data.nh3.critical).toFixed(1);
    $("nh3_realert_min").value = data.nh3.realertMin;
    setSwitch("nh3", data.nh3.alert);

    $("hum_high").value = data.hum.high;
    $("hum_low").value  = data.hum.low;
    $("hum_realert_min").value = data.hum.realertMin;
    $("people_high").value = data.people.high;
    $("towel_threshold").value = data.towel.threshold;
    $("soap_threshold").value = data.soap.threshold;
    
    setSwitch("hum", data.hum.alert);
    setSwitch("people", data.people.alert);
    setSwitch("towel", data.towel.alert);
    setSwitch("soap", data.soap.alert);
  }

  function loadFromServer() {
    fetch(contextPath + "/threshold/getSettings.do")
      .then(function(res) { 
          if(!res.ok) throw new Error("서버 에러 발생");
          return res.json(); 
      })
      .then(function(data) {
        // ✅ 데이터 상자가 비어있을 경우 초기값 세팅 후 종료 (에러 방지)
        if (!data || !data.thresholds) {
            setFormData(DEFAULTS);
            return;
        }

        var dbData = { temp: {}, hum: {}, nh3: {}, people: {}, towel: {}, soap: {} };

        // 1. 임계값(Thresholds) 리스트 매핑
        data.thresholds.forEach(function(t) {
          if (!t.sensorType) return;
          var key = t.sensorType.toLowerCase();
          if (key === "humidity") key = "hum";
          if (key === "people_in") key = "people";
          
          if (dbData[key]) {
            if (key === "nh3") {
                dbData[key].warning = t.minValue;
                dbData[key].critical = t.maxValue;
            } else {
                dbData[key].high = t.maxValue;
                dbData[key].low = t.minValue;
            }
            dbData[key].realertMin = t.alertInterval;
          }
        });

        // 2. 알림 설정 매핑
        if (data.alerts) {
            data.alerts.forEach(function(a) {
              var key = a.sensorType.toLowerCase();
              if (key === "humidity") key = "hum";
              if (key === "people_in") key = "people";
              if (key === "paper_towel") key = "towel";
              if (key === "liquid_soap") key = "soap";
              if (dbData[key]) dbData[key].alert = (a.isEnabled === 1);
            });
        }

        // 3. 소모품 설정 매핑
        if (data.consumables) {
            data.consumables.forEach(function(c) {
              var key = c.typeKey.toLowerCase();
              if (key === "paper_towel") dbData.towel.threshold = c.threshold;
              if (key === "liquid_soap") dbData.soap.threshold = c.threshold;
            });
        }

        setFormData(dbData); 
      })
      .catch(function(err) {
        console.error("데이터 로드 실패:", err);
        setFormData(DEFAULTS); // 에러 시 초기값 출력
      });
  }

  function saveToServer(data) {
    return fetch(contextPath + "/threshold/saveSettings.do", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data)
    });
  }

  function onSave() {
    var data = getFormData();
    
    saveToServer(data)
      .then(function (res) { 
          return res.json(); // ✅ 1. 문자열(text)이 아닌 JSON으로 받습니다.
      }) 
      .then(function (result) {
        // ✅ 2. 객체 내부의 status 필드가 "success"인지 확인합니다.
        if (result.status === "success") { 
          showToast("데이터베이스에 저장되었습니다.");
          setFormData(data); 
        } else {
          showToast("저장에 실패했습니다.");
        }
      })
      .catch(function(err) {
        console.error("저장 중 오류 발생:", err);
        showToast("서버 연결 실패");
    });
}

  function onReset() {
    setFormData(DEFAULTS);
    showToast("화면이 기본값으로 설정되었습니다. (저장을 눌러야 반영됩니다)");
  }

  function init() {
    if (typeof contextPath === "undefined") window.contextPath = "";

    var btnSave = $("btnSave");
    var btnReset = $("btnReset");
    if (btnSave) btnSave.addEventListener("click", onSave);
    if (btnReset) btnReset.addEventListener("click", onReset);

    document.querySelectorAll(".switch[data-toggle]").forEach(function(sw) {
      sw.addEventListener("click", function() { toggleSwitchEl(sw); });
    });

    loadFromServer(); 
    setLayoutVars();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();