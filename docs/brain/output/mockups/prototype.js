// All actions are local prototype transitions; no real permission or API requests.
const params = new URLSearchParams(location.search);
const appearance=params.get('appearance');
if(['light','dark'].includes(appearance)) document.documentElement.dataset.appearance=appearance;
const interactive = params.get('demo') === '1';
document.querySelectorAll('a[href^="screen-"]').forEach(a => {
 const target=new URL(a.getAttribute('href'),location.href);
 if(interactive) target.searchParams.set('demo','1');
 if(appearance) target.searchParams.set('appearance',appearance);
 a.href=target.href;
});
document.querySelectorAll('[data-detail-link]').forEach(link=>{
 const target=new URL(link.href);
 ['place','rating','reviews','price','type','about','address'].forEach(field=>{
  if(link.dataset[field]) target.searchParams.set(field,link.dataset[field]);
 });
 link.href=target.href;
});
if (interactive && location.pathname.endsWith('screen-05-loading.html')) setTimeout(() => location.href = 'screen-06-result.html?demo=1' + (appearance ? '&appearance='+appearance : ''), 4500);
if (interactive && location.pathname.endsWith('screen-01-launch.html')) location.replace('screen-02-welcome.html?demo=1' + (appearance ? '&appearance='+appearance : ''));
if(params.get('variant') === 'service') {
 const title=document.getElementById('error-title');
 if(title){ title.textContent='The search couldn’t finish.';document.getElementById('error-body').textContent='Restaurant recommendations are temporarily unavailable. Please try again in a moment.';document.getElementById('error-kicker').textContent='A brief interruption'; document.querySelector('.signal-art').innerHTML='<svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 6v6l4 2"/></svg>';  }
}

// Recovery artwork is decorative; the adjacent heading and body carry the state.
const recoveryArtwork={
 'screen-07-permission-denied.html':'state-location-off-illustration.png',
 'screen-08-no-results.html':'state-no-results-illustration.png',
 'screen-09-network-error.html':'state-network-error-illustration.png'
};
const recoveryAsset=Object.entries(recoveryArtwork).find(([screen])=>location.pathname.endsWith(screen))?.[1];
const recoveryGraphic=document.querySelector('.state-graphic');
if(recoveryAsset&&recoveryGraphic){
 const image=document.createElement('img');
 image.className='state-illustration';
 image.src=recoveryAsset;
 image.alt='';
 image.setAttribute('aria-hidden','true');
 recoveryGraphic.replaceChildren(image);
}
const handoffDialog=document.getElementById('demo-dialog');
document.querySelectorAll('[data-action]').forEach(button => button.addEventListener('click',()=>{
 const settings=button.dataset.action==='settings';
 const selectedPlace=button.dataset.place;
 document.getElementById('dialog-title').textContent=settings?'Settings handoff':'Directions handoff';
 document.getElementById('dialog-copy').textContent=settings?'In the iOS app, this opens HungryNow’s settings. This HTML preview does not change your permissions.':`In the iOS app, this opens a maps app using ${selectedPlace ? `${selectedPlace}’s` : 'the restaurant’s'} verified coordinates. The sample restaurant data in this preview is not a live recommendation.`;
 handoffDialog.showModal();
}));

const detailContent=document.getElementById('place-detail-content');
if(detailContent){
 const detailScroll=document.querySelector('.screen-place-detail .detail-main');
 const detailAppbar=document.querySelector('.screen-place-detail .detail-appbar');
 const updateDetailAppbar=()=>detailAppbar?.classList.toggle('scrolled',detailScroll.scrollTop>=36);
 if(detailScroll){
  detailScroll.addEventListener('scroll',updateDetailAppbar,{passive:true});
  updateDetailAppbar();
 }
 const detailValues={
  'detail-place-name':params.get('place'),
  'detail-rating':params.get('rating'),
  'detail-review-score':params.get('rating'),
  'detail-review-count':params.get('reviews'),
  'detail-review-total':params.get('reviews'),
  'detail-price':params.get('price'),
  'detail-type':params.get('type'),
  'detail-about':params.get('about'),
  'detail-recommendation-reason':params.get('about'),
  'detail-address':params.get('address')
 };
 Object.entries(detailValues).forEach(([id,value])=>{if(value) document.getElementById(id).textContent=value;});
 const detailDirections=document.getElementById('detail-directions');
 if(detailDirections) detailDirections.dataset.place=params.get('place')||'the selected restaurant';
 const selectDetailTab=tabName=>{
  document.querySelectorAll('[data-detail-tab]').forEach(tab=>tab.setAttribute('aria-selected',String(tab.dataset.detailTab===tabName)));
  document.querySelectorAll('.detail-panel').forEach(panel=>{panel.hidden=panel.id!==`${tabName}-panel`;});
 };
 document.querySelectorAll('[data-detail-tab]').forEach(tab=>tab.addEventListener('click',()=>selectDetailTab(tab.dataset.detailTab)));
 selectDetailTab(params.get('tab')==='reviews'?'reviews':'overview');
 const reviewList=document.querySelector('.review-list');
 const reviewLoadState=document.getElementById('review-load-state');
 const reviewFixtures=[
  ['AR','Aisha R.',5,'The rice was fragrant, the curries had plenty of depth, and service stayed friendly even when the counter became busy.','2026-03','6 months ago'],
  ['BL','Ben L.',4,'Easy to find and straightforward to order. The portions were generous enough to share.','2026-02','7 months ago'],
  ['SK','Sinta K.',5,'A good variety of vegetables and curries, with staff happy to explain the unfamiliar dishes.','2026-01','8 months ago'],
  ['OM','Omar M.',4,'Quick counter service and a lively dining room. Arriving before the dinner rush made ordering easier.','2025-12','9 months ago'],
  ['CL','Chen L.',5,'The curry selection was the highlight, and everything we tried tasted freshly prepared.','2025-11','10 months ago']
 ];
 const appendReview=([initials,name,rating,copy,date,label])=>{
  const article=document.createElement('article');
  article.className='review-card';
  article.innerHTML=`<div class="review-head"><div class="review-person"><span class="review-avatar" aria-hidden="true">${initials}</span><strong>${name}</strong></div><span class="review-stars" aria-label="${rating} out of 5 stars">${'★'.repeat(rating)}${'☆'.repeat(5-rating)}</span></div><p>${copy}</p><time datetime="${date}">${label}</time>`;
  reviewList.append(article);
 };
 if(detailScroll&&reviewList&&reviewLoadState&&'IntersectionObserver' in window){
  let loadingReviews=false;
  const reviewObserver=new IntersectionObserver(entries=>{
   if(!entries.some(entry=>entry.isIntersecting)||loadingReviews||reviewFixtures.length===0) return;
   loadingReviews=true;
   reviewList.setAttribute('aria-busy','true');
   setTimeout(()=>{
    reviewFixtures.splice(0,3).forEach(appendReview);
    reviewList.setAttribute('aria-busy','false');
    loadingReviews=false;
    if(reviewFixtures.length===0){
     reviewLoadState.hidden=true;
     reviewObserver.disconnect();
    }
   },300);
  },{root:detailScroll,rootMargin:'0px 0px 160px'});
  reviewObserver.observe(reviewLoadState);
 }else if(reviewLoadState) reviewLoadState.hidden=true;
 const detailState=params.get('state');
 if(detailState==='loading'||detailState==='error'){
  detailContent.hidden=true;
  document.getElementById(`place-detail-${detailState}`).hidden=false;
 }
}

const track=document.querySelector('.photo-track');
if(track){
 const count=document.getElementById('photo-count');
 const photos=[...track.querySelectorAll('img')];
 const page=()=>Math.round(track.scrollLeft / track.clientWidth);
 const updatePhotoIndicator=()=>{
  const current=page();
  count?.querySelectorAll('.photo-dot').forEach((dot,index)=>dot.classList.toggle('active',index===current));
  if(count) count.setAttribute('aria-label',`Photo ${current+1} of ${photos.length}`);
 };
 document.querySelectorAll('[data-photo]').forEach(b=>b.addEventListener('click',()=>{
  const next=(page()+Number(b.dataset.photo)+photos.length)%photos.length;
  track.scrollTo({left:next*track.clientWidth,behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'instant':'smooth'});
 }));
 track.addEventListener('scroll',updatePhotoIndicator,{passive:true});
 updatePhotoIndicator();
}

// Home plate: the hands are set once from the device clock (static, not ticking);
// the label names the meal window, which is the part that carries meaning.
// Window edges are decimal hours. Anything outside them is late night.
const MEAL_WINDOWS=[[5,10.5,'Breakfast'],[10.5,15,'Lunch'],[15,18,'Afternoon'],[18,22,'Dinner']];
const plateLabel=document.getElementById('meal-window');
if(plateLabel){
 const hourHand=document.querySelector('.hand-hour');
 const minuteHand=document.querySelector('.hand-minute');
 const setPlate=()=>{
  const now=new Date(), h=now.getHours(), m=now.getMinutes(), dec=h+m/60;
  const win=MEAL_WINDOWS.find(([from,to])=>dec>=from&&dec<to);
  plateLabel.textContent=win?win[2]:'Late night';
  if(hourHand) hourHand.style.transform=`rotate(${(h%12)*30+m*0.5}deg)`;
  if(minuteHand) minuteHand.style.transform=`rotate(${m*6}deg)`;
 };
 setPlate();
 // Re-read on return from background: a tourist can cross a timezone between opens.
 document.addEventListener('visibilitychange',()=>{if(!document.hidden) setPlate();});
}
