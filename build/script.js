document.addEventListener('DOMContentLoaded', async function() {
    let counterElement = document.getElementById('visitor-counter');
    try {
        let response = await fetch("https://bt58yyqlxc.execute-api.us-east-1.amazonaws.com/prod/views");
        let data = await response.json();
        counterElement.innerHTML = `Visitors: ${data.views}`;
    } catch (error) {
        console.error('Error fetching visitor count:', error);
    }
});