const menu = document.querySelector("#nav-menu");
const toggle = document.querySelector("#menu-toggle");

toggle?.addEventListener("click", () => {
  menu?.classList.toggle("invisible");
});

menu?.addEventListener("click", (_) => {
  menu?.classList.add("invisible");
});
