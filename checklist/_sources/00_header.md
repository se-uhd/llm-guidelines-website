---
layout: default
title: Checklist
nav_order: 6
has_children: false
---

<style>
.main-content ul {
  list-style: none !important;
  padding-left: 0 !important;
}
.main-content ul li::before {
  content: none !important;
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
.main-content ul li.cond-hidden {
  display: none !important;
}
#checklist-reset,
#checklist-export,
#filters-toggle {
  cursor: pointer;
}
#checklist-export {
  margin-left: 0.5em;
}
.marker-should { color: #ddd; }

.condition {
  display: inline-block;
  padding: 0 0.4em;
  margin-right: 0.3em;
  font-size: 0.78em;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  background-color: #eee;
  color: #555;
  border-radius: 0.25em;
  white-space: nowrap;
  vertical-align: 0.05em;
}

#condition-filters {
  border: 1px solid #ddd;
  border-radius: 0.3em;
  padding: 0.5em 0.8em;
  margin: 1.2em 0;
  background-color: #fafafa;
}
#condition-filters[open] {
  padding-bottom: 0.85em;
}
#condition-filters + h2 {
  margin-top: 1.2em;
}
#condition-filters > summary {
  cursor: pointer;
  font-weight: 600;
  color: #555;
  padding: 0.2em 0;
  list-style: none;
}
#condition-filters > summary::-webkit-details-marker {
  display: none;
}
#condition-filters > summary::before {
  content: "\25B6";
  display: inline-block;
  margin-right: 0.4em;
  transition: transform 0.15s;
  font-size: 0.7em;
  vertical-align: 0.15em;
}
#condition-filters[open] > summary::before {
  transform: rotate(90deg);
}
.filter-parent-heading {
  font-weight: 700;
  font-size: 0.95em;
  margin: 0.6em 0 0 !important;
  padding-top: 0.6em;
  border-top: 1px solid #e0e0e0;
  color: #333;
}
.filter-parent-heading:first-of-type {
  margin-top: 0.4em !important;
}
.filter-section {
  border-top: 1px solid #e0e0e0;
  padding-top: 0.5em;
  margin: 0.5em 0 0 0.8em;
}
.filter-section-title {
  font-weight: 600;
  font-size: 0.85em;
  margin: 0 0 0.3em !important;
  color: #555;
}
.filter-actions {
  border-top: 1px solid #e0e0e0;
  padding-top: 0.6em;
  margin-top: 0.6em;
}
.filter-actions > button {
  margin-bottom: 0;
}
.filter-actions > button + button {
  margin-left: 0.5em;
}
.filter-grid {
  display: grid !important;
  grid-template-columns: repeat(auto-fill, minmax(12em, 1fr));
  gap: 0.4em 1em;
}
.filter-grid > label {
  display: block !important;
  font-size: 0.9em;
  cursor: pointer;
  margin: 0 !important;
}
#condition-filters input[type="checkbox"] {
  cursor: pointer;
  margin-right: 0.3em;
}
#filters-toggle {
  margin-top: 0.5em;
}
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

  /* Conditional-filter state (independent of per-item checkbox state) */

  var COND_KEY = "llm-guidelines-checklist-conditions";

  function loadCondState() {
    try {
      var arr = JSON.parse(localStorage.getItem(COND_KEY)) || [];
      return new Set(arr);
    } catch (e) {
      return new Set();
    }
  }

  function saveCondState(set) {
    var arr = [];
    set.forEach(function (v) { arr.push(v); });
    localStorage.setItem(COND_KEY, JSON.stringify(arr));
  }

  function applyCondFilter() {
    var hidden = loadCondState();
    items.forEach(function (li) {
      var chips = li.querySelectorAll(".condition[data-condition]");
      var shouldHide = false;
      chips.forEach(function (chip) {
        if (hidden.has(chip.getAttribute("data-condition"))) shouldHide = true;
      });
      if (shouldHide) li.classList.add("cond-hidden");
      else li.classList.remove("cond-hidden");
    });
  }

  /* Each checkbox change auto-applies; toggle button checks/unchecks all
     and also auto-applies. */
  var filterBoxes = document.querySelectorAll(".cond-filter");
  var initialHidden = loadCondState();
  filterBoxes.forEach(function (cb) {
    cb.checked = !initialHidden.has(cb.getAttribute("data-condition"));
  });

  /* Copy each filter label's tooltip onto every chip with the matching
     data-condition, so hovering a [tag] chip in a bullet shows the same
     description as the filter checkbox. Single source of truth in the
     filter UI HTML; chips inherit at runtime. */
  filterBoxes.forEach(function (cb) {
    var slug = cb.getAttribute("data-condition");
    var labelEl = cb.parentElement;
    var title = labelEl ? labelEl.getAttribute("title") : null;
    if (!title) return;
    document.querySelectorAll('.condition[data-condition="' + slug + '"]').forEach(function (chip) {
      chip.setAttribute("title", title);
    });
  });

  function commitFiltersFromUI() {
    var s = new Set();
    filterBoxes.forEach(function (cb) {
      if (!cb.checked) s.add(cb.getAttribute("data-condition"));
    });
    saveCondState(s);
    applyCondFilter();
  }

  filterBoxes.forEach(function (cb) {
    cb.addEventListener("change", commitFiltersFromUI);
  });

  var filtersToggle = document.getElementById("filters-toggle");
  if (filtersToggle) {
    filtersToggle.addEventListener("click", function () {
      var anyChecked = false;
      filterBoxes.forEach(function (cb) { if (cb.checked) anyChecked = true; });
      var newState = !anyChecked;
      filterBoxes.forEach(function (cb) { cb.checked = newState; });
      commitFiltersFromUI();
    });
  }

  applyCondFilter();

  document.getElementById("checklist-export").addEventListener("click", function () {
    var rows = [["Section", "Requirement Level", "Item Text", "Tags", "Guideline", "Status"]];

    items.forEach(function (li) {
      /* Filter respect: items hidden by the filter panel are excluded from
         the export so the CSV reflects what the author actually sees. */
      if (li.classList.contains("cond-hidden")) return;

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

      var tagSlugs = [];
      li.querySelectorAll(".condition[data-condition]").forEach(function (chip) {
        tagSlugs.push(chip.getAttribute("data-condition"));
      });
      var tags = tagSlugs.join(", ");

      var guideline = "";
      var link = li.querySelector("a");
      if (link) {
        var gMatch = link.textContent.match(/^G\d+$/);
        if (gMatch) guideline = gMatch[0];
      }

      var cleanText = text
        .replace(/^[\u25CF\u25CB]\s*/, "")
        .replace(/\s*\[[a-z0-9-]+\]\s*/g, " ")
        .replace(/\s*\(G\d+\)\.?\s*$/, "")
        .replace(/\s+/g, " ")
        .trim();

      var cb = li.querySelector("input[type='checkbox']");
      var status = cb && cb.checked ? "checked" : "unchecked";

      rows.push([section, level, cleanText, tags, guideline, status]);
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
