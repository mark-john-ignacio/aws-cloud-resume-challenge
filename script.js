document.addEventListener('DOMContentLoaded', async function() {
    let counterElement = document.getElementById('visitor-counter');
    try {
        let response = await fetch("https://63jrqmlhvdp3fkavgrurlhry4e0xpllz.lambda-url.us-east-1.on.aws/");
        let count = await response.json(); // Assuming the response is in JSON format
        counterElement.innerHTML = `Visitors: ${count}`;
    } catch (error) {
        console.error('Error fetching visitor count:', error);
    }
});