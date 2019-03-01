const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => res.send('Hello World!'))
app.get('/alive', (req, res) => res.send(200))
app.get('/ready', (req, res) => res.send(200))

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
