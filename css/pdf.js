function horizontal(img)
{
	return img.getAttribute("data-heightRatio") < 1;
}

function format()
{	
	//legends formating
	var legends = document.getElementsByClassName("gallery-legend");
	for(var i=0; i<legends.length; i++)
	{
		legends[i].style.textAlign = "left";
		legends[i].style.display = "block";
		
		//legend title bolding
		legends[i].getElementsByClassName("gallery-legend-title")[0].style.fontWeight = "bold";
		
		//lines breaking
		var glep = legends[i].getElementsByClassName("gallery-legend-element-position");
		for(var j=0; j<glep.length; j++)
		{
			glep[j].style.display = "inline";
			var breaker = document.createElement("br");
			breaker.style.display = "block";
			breaker.style.marginBottom = "5px";
			glep[j].parentNode.insertBefore(breaker, glep[j]);
		}
	}
	
	
	//galleries formating
	var galleries = document.getElementsByClassName("womi-gallery");
	i=0;
	while(i < galleries.length) {

		var divs = galleries[i].getElementsByClassName("image-container");
		for (k=0; k < divs.length; k++)
		{
			//image-container
			divs[k].style.display = "inline";
			
			//pdf
			divs[k].parentNode.style.display = "inline";
			
			if(divs[k].parentNode.getElementsByClassName("womi-caption").length > 0) divs[k].parentNode.getElementsByClassName("womi-caption")[0].style.display = "none";
			if(divs[k].parentNode.getElementsByClassName("womi-associated-text").length > 0) divs[k].parentNode.getElementsByClassName("womi-associated-text")[0].style.display = "none";
			
			//womi-container
			divs[k].parentNode.parentNode.style.display = "inline-block";
			
			//li
			divs[k].parentNode.parentNode.parentNode.style.display = "inline";
			divs[k].parentNode.parentNode.parentNode.style.margin = "0px";
			divs[k].parentNode.parentNode.parentNode.style.padding = "0px";
		}
		
		//get all images
		var images = Array.prototype.slice.call(galleries[i].getElementsByClassName("womi-gallery-contents")[0].getElementsByTagName("img"));
		var otherWomiContainer = galleries[i].getElementsByClassName("womi-gallery-contents-others");
		if(otherWomiContainer.length > 0) {
			var tmp =otherWomiContainer[0].getElementsByTagName("ol");
			if(tmp.length > 0) {
				images = images.concat(Array.prototype.slice.call(tmp[0].getElementsByTagName("img")));
			}
		}
		
		
		for(var j=images.length-1; j>=0; j--)
		{
			//removing images QRCodes from movies galleries
			if(images[j].parentNode.parentNode.className == "qr-code") images[j].parentNode.parentNode.parentNode.removeChild(images[j].parentNode.parentNode);
			
			//removing Gallery QRCodes from array
			if(images[j].parentNode.className == "qr-code-gallery") images.splice(j,1);
			else if(images[j].parentNode.className == "qr-code") images.splice(j,1);
		}
		
		//number inserting
		for(var j=0; j<images.length; j++)
		{
			var paragraph = document.createElement("p");
			var number = document.createTextNode((j+1).toString() + ".");
			paragraph.style.verticalAlign = "top";
			paragraph.style.fontSize = "12px";
			paragraph.style.marginRight = "3px";
			paragraph.style.display = "inline";
			paragraph.appendChild(number);
			if(images[j].parentNode.tagName != "a") images[j].parentNode.insertBefore(paragraph, images[j]);
			else images[j].parentNode.parentNode.insertBefore(paragraph, images[j].parentNode);
			
			//images positioning
			images[j].style.verticalAlign = "top";
			images[j].style.marginTop = "0px";
			images[j].style.marginBottom = "10px";

		}
		
		//images reformating
		j=0;
		while(j < images.length) {

			jump=0;
			
			//images pairs
			if(j+1<images.length) {

				var hr1 = images[j].getAttribute("data-heightRatio");
				var hr2 = images[j+1].getAttribute("data-heightRatio");
			
				var rhr1 = 1/hr1;
				var rhr2 = 1/hr2;
				
				var shr = rhr1 + rhr2;
				
				var w1 = 86 * rhr1/shr;
				
				if(w1 > 70) w1 = 70;
				else if(w1 < 30) w1 = 30;
				
				var w2 = 86 - w1;
				
				w1 = w1 + 5;
				w2 = w2 + 5;
			
				if(images[j].parentNode.tagName != "a") {images[j].parentNode.parentNode.parentNode.style.maxWidth = w1.toString() + "%"; /*images[j].style.border = "5px solid red";*/}
				else {images[j].parentNode.parentNode.parentNode.parentNode.style.maxWidth = w1.toString() + "%";}
				
				if(images[j+1].parentNode.tagName != "a") {images[j+1].parentNode.parentNode.parentNode.style.maxWidth = w2.toString() + "%"; /*images[j+1].style.border = "5px solid pink";*/}
				else images[j+1].parentNode.parentNode.parentNode.parentNode.style.maxWidth = w2.toString() + "%";
				
				var iw1 = 100 - (500/w1);
				var iw2 = 100 - (500/w2);
				
				images[j].style.maxWidth = iw1.toString() + "%";
				images[j+1].style.maxWidth = iw2.toString() + "%";
				jump=2;
				
			}
			
			//extremely horizontal image
			if(images[j].getAttribute("data-heightRatio") < 0.25)
			{
				if(images[j].parentNode.tagName != "a") {images[j].parentNode.parentNode.parentNode.style.maxWidth = "100%"; /*images[j].style.border = "5px solid blue";*/}
				else images[j].parentNode.parentNode.parentNode.parentNode.style.maxWidth = "100%";
				
				images[j].style.maxWidth = "95%";
				jump=1;
			}
			
			//extremely horizontal next image
			if(j+1<images.length) {
				if(images[j+1].getAttribute("data-heightRatio") < 0.25)
				{
					if(images[j].parentNode.tagName != "a") {images[j].parentNode.parentNode.parentNode.style.maxWidth = "100%"; /*images[j].style.border = "5px solid violet";*/}
					else images[j].parentNode.parentNode.parentNode.parentNode.style.maxWidth = "100%";
					
					if(images[j+1].parentNode.tagName != "a") {images[j+1].parentNode.parentNode.parentNode.style.maxWidth = "100%"; /*images[j+1].style.border = "5px solid green";*/}
					else images[j+1].parentNode.parentNode.parentNode.parentNode.style.maxWidth = "100%";
				
					images[j].style.maxWidth = "95%";
					images[j+1].style.maxWidth = "95%";
					jump=2;
				}
			}
			
			//vertical images triples
			if(j+2<images.length) {
				if(!horizontal(images[j]) && !horizontal(images[j+1]) && !horizontal(images[j+2]))
				{
					if(images[j].parentNode.tagName != "a") {images[j].parentNode.parentNode.parentNode.style.maxWidth = "32%"; /*images[j].style.border = "5px solid yellow";*/}
					else images[j].parentNode.parentNode.parentNode.parentNode.style.maxWidth = "32%";
					
					if(images[j+1].parentNode.tagName != "a") {images[j+1].parentNode.parentNode.parentNode.style.maxWidth = "32%"; /*images[j+1].style.border = "5px solid orange";*/}
					else images[j+1].parentNode.parentNode.parentNode.parentNode.style.maxWidth = "32%";
					
					if(images[j+2].parentNode.tagName != "a") {images[j+2].parentNode.parentNode.parentNode.style.maxWidth = "32%"; /*images[j+2].style.border = "5px solid gray";*/}
					else images[j+2].parentNode.parentNode.parentNode.parentNode.style.maxWidth = "32%";
					
					images[j].style.maxWidth = "86%";
					images[j+1].style.maxWidth = "86%";
					images[j+2].style.maxWidth = "86%";
					jump=3;
				}
			}
			
			
			//single image in the line
			if(jump == 0) {
				if(horizontal(images[j]))images[j].style.maxWidth = "95%";
				else images[j].style.maxWidth = "60%";
				
				jump=1;
			}
			
			j+=jump;
		}
		i++;
	}
}

//hide empty womi captions
function formatWomiAside() {
	var asides = document.getElementsByClassName("womi-aside");
	for(var i=0; i<asides.length; i++) {
		var aside = asides[i];
		var captions = aside.getElementsByClassName("pdf")[0].getElementsByClassName("womi-caption");

		//check if womi caption is empty
		if(captions.length>0 && captions[0].textContent.length==0) {
			captions[0].style.display = "none";
		}
	}
}

window.onload = function(){
	format();
	formatWomiAside();
}
