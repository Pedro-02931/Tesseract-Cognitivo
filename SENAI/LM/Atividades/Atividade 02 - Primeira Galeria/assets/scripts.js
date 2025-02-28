// Seleciona elementos uma vez
const navbar = document.querySelector('.navbar');
const gallery = document.getElementById('gallery');

// Função para esconder/exibir a navbar com transição suave
function toggleNavbar() {
    navbar.classList.toggle('hidden');
}

// Criando a galeria dinamicamente de forma otimizada
const fragment = document.createDocumentFragment(); // Evita reflow desnecessário

for (let i = 0; i < 9; i++) {
    const imgContainer = document.createElement('div');
    imgContainer.classList.add('gallery-item');

    const img = document.createElement('img');
    img.src = `/assets/img/${i}.png`;
    img.alt = `Imagem ${i}`;

    imgContainer.appendChild(img);
    fragment.appendChild(imgContainer);
}

gallery.appendChild(fragment); // Adiciona tudo de uma vez no DOM para melhor performance
