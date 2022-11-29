function setCurrentDate(element) {
    date = new Date().toLocaleDateString();
    //element.setAttribute("content", date);
    //document.write(date);
    element.innerText = date;
    console.log(element);
}