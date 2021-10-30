<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Kratu's projects - coaru.com</title>
	<style>
		@import url('https://fonts.googleapis.com/css2?family=Courier+Prime&family=Press+Start+2P&display=swap');
		body { margin: 0; font-family: 'Courier Prime', monospace; font-size: 1.4em; }
		#main { margin: 0; height: 100vh; background-color: #040404; display: flex; justify-content: center; align-items:center; }
		h1 { font-family: 'Press Start 2P', monospace; color: #1992CA; text-align: center; font-size: 1.2em; }
		a, a:visited { color: #16bdcc; text-decoration: none; }
		a:hover, a:focus { color: #004666; }
		.text-center { text-align: center; }
	</style>
</head>
<body>
	<div id="main">
		<div style="color:#ffffff">
			<h1>Kratu's projects</h1>
			<p class="text-center">Server block is ready!</p>
			<p class="text-center">User: <strong><?php echo `whoami`; ?>></strong></p>
			<p class="text-center"><small><a href="https://coaru.com" target="_blank">coaru.com</a></small></p>
		</div>
	</div>
</body>
</html>
