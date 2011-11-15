//テキストボックスに予め文字を入れておきフォーカスがあたったら消える
$(function(){
	$("#tweet").val("つぶやく内容を書く").css("color","#969696");
	$("#tweet").focus(function(){
		if(this.value == "つぶやく内容を書く"){
			$(this).val("").css("color","#000");
		}
	});
	$("#tweet").blur(function(){
		if(this.value == ""){
			$(this).val("つぶやく内容を書く")
			     .css("color","#969696");
		}
		if(this.value != "つぶやく内容を書く"){
			$(this).css("color","#000");
		}
	});
});
