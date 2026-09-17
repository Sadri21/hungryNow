// Design-review controls only. No device appearance settings are changed.
function showAppearance(value){
 document.querySelectorAll('iframe').forEach(frame=>{const url=new URL(frame.src);url.searchParams.set('appearance',value);frame.src=url.href;});
 document.querySelectorAll('a[href^="screen-"]').forEach(a=>{const url=new URL(a.href);url.searchParams.set('appearance',value);a.href=url.href;});
 document.querySelectorAll('[data-appearance]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.appearance===value)));
}
document.querySelectorAll('[data-appearance]').forEach(b=>b.addEventListener('click',()=>showAppearance(b.dataset.appearance)));
showAppearance('light');
