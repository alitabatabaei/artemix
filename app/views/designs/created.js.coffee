window.design_created(<%= @design.id %>)
window.alert('<%= @design.designer %>, thank you for submitting your design! The Bombsheller team will review it and reach out to you with questions. Thanks for being a Bombshell!')
location.reload()