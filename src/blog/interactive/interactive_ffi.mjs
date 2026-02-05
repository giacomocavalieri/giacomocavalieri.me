export function do_scroll_to(id) {
  const element = document.getElementById(id);
  if (element !== null) {
    element.scrollIntoView({ behavior: "smooth", block: "center" });
  }
  return undefined;
}

export function do_focus_no_scroll(id) {
  const element = document.getElementById(id);
  if (element !== null) {
    element.focus({ preventScroll: true });
  }
  return undefined;
}

export function after(ms, fun) {
  return setTimeout(() => fun(), ms);
}

export function stop_timer(timer) {
  clearTimeout(timer);
  return undefined;
}
