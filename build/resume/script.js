document.addEventListener('DOMContentLoaded', async function() {
    let counterElement = document.getElementById('visitor-counter');
    try {
        let response = await fetch("https://7kjzfvb11h.execute-api.us-east-1.amazonaws.com/prod/views", {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id: 1 })
        });
        let data = await response.json();
        console.log(data);
        counterElement.innerHTML = `${data.views}`;
    } catch (error) {
        console.error('Error fetching visitor count:', error);
    }
});