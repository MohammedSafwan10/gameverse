document.querySelectorAll('[data-game]').forEach((button) => {
  button.addEventListener('click', () => document.getElementById(button.dataset.game).showModal());
});
document.querySelectorAll('[data-release]').forEach((button) => {
  button.addEventListener('click', (event) => {
    event.preventDefault();
    document.getElementById('release-dialog').showModal();
  });
});
document.querySelectorAll('dialog').forEach((dialog) => {
  dialog.querySelectorAll('[data-close]').forEach((button) => button.addEventListener('click', () => dialog.close()));
  dialog.addEventListener('click', (event) => {
    const box = dialog.getBoundingClientRect();
    if (event.target === dialog && (event.clientX < box.left || event.clientX > box.right || event.clientY < box.top || event.clientY > box.bottom)) dialog.close();
  });
});
document.querySelectorAll('.mobile-nav a').forEach((link) => link.addEventListener('click', () => { link.closest('details').open = false; }));
