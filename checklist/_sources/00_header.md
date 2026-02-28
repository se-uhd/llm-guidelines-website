---
layout: default
title: Checklist
nav_order: 5
has_children: false
---

<style>
.main-content ul {
  list-style: none;
  padding-left: 0;
}
.main-content ul li {
  position: relative;
  padding-left: 1.8em;
  margin-bottom: 0.3em;
}
.main-content ul li input[type="checkbox"] {
  position: absolute;
  left: 0;
  top: 0.25em;
  cursor: pointer;
}
.main-content ul li.checked {
  opacity: 0.5;
}
#checklist-reset,
#checklist-export {
  margin-bottom: 0;
  cursor: pointer;
}
#checklist-export {
  margin-left: 0.5em;
}
.marker-should { color: #ddd; }
</style>

<!-- RESET_BUTTON -->

<script>
document.addEventListener("DOMContentLoaded", function () {
  var STORAGE_KEY = "llm-guidelines-checklist";

  function hashString(str) {
    var hash = 5381;
    for (var i = 0; i < str.length; i++) {
      hash = ((hash << 5) + hash + str.charCodeAt(i)) & 0xffffffff;
    }
    return hash.toString(36);
  }

  function loadState() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {};
    } catch (e) {
      return {};
    }
  }

  function saveState(state) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }

  var state = loadState();
  var items = document.querySelectorAll(".main-content li");

  items.forEach(function (li) {
    var text = li.textContent.trim();
    var key = hashString(text);
    var cb = document.createElement("input");
    cb.type = "checkbox";
    cb.checked = !!state[key];
    if (cb.checked) li.classList.add("checked");

    cb.addEventListener("change", function () {
      var s = loadState();
      if (cb.checked) {
        s[key] = true;
        li.classList.add("checked");
      } else {
        delete s[key];
        li.classList.remove("checked");
      }
      saveState(s);
    });

    li.insertBefore(cb, li.firstChild);
  });

  document.getElementById("checklist-reset").addEventListener("click", function () {
    localStorage.removeItem(STORAGE_KEY);
    items.forEach(function (li) {
      var cb = li.querySelector("input[type='checkbox']");
      if (cb) cb.checked = false;
      li.classList.remove("checked");
    });
  });

  document.getElementById("checklist-export").addEventListener("click", function () {
    var rows = [["Section", "Requirement Level", "Item Text", "Guideline", "Status"]];

    items.forEach(function (li) {
      var section = "";
      var el = li.parentElement;
      while (el && el.previousElementSibling) {
        el = el.previousElementSibling;
        if (el.tagName === "H2" || el.tagName === "H3") {
          section = el.textContent.trim();
          break;
        }
      }

      var text = li.textContent.trim();

      var level = "";
      if (li.querySelector(".marker-should")) level = "SHOULD";
      else if (text.charAt(0) === "\u25CF") level = "MUST";

      var guideline = "";
      var link = li.querySelector("a");
      if (link) {
        var gMatch = link.textContent.match(/^G\d+$/);
        if (gMatch) guideline = gMatch[0];
      }

      var cleanText = text
        .replace(/^[\u25CF\u25CB]\s*/, "")
        .replace(/\s*\(G\d+\)\.?\s*$/, "")
        .trim();

      var cb = li.querySelector("input[type='checkbox']");
      var status = cb && cb.checked ? "checked" : "unchecked";

      rows.push([section, level, cleanText, guideline, status]);
    });

    var csv = rows.map(function (row) {
      return row.map(function (field) {
        return '"' + field.replace(/"/g, '""') + '"';
      }).join(",");
    }).join("\n");

    var blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = url;
    a.download = "llm-guidelines-checklist.csv";
    a.click();
    URL.revokeObjectURL(url);
  });
});
</script>

