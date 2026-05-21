// Landing page enhancement script.
// Imports the stylesheet so Vite picks it up, and wires smooth-scroll on anchor links.
import '../../style.css';

document.querySelectorAll('a[href^="#"]').forEach((a) => {
    a.addEventListener('click', (e) => {
        const id = a.getAttribute('href');
        if (id.length < 2) return;
        const t = document.querySelector(id);
        if (!t) return;
        e.preventDefault();
        t.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
});
