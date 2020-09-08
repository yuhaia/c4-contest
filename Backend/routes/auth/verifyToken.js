var jwt = require('jsonwebtoken')
const config = require('config-lite')(__dirname)

function verifyToken(req, res, next) {
  var token = req.headers['token'];
  if (!token)
    return res.status(403).send({ 'error': 'No token provided.' });
    
  jwt.verify(token, config.auth_secret, function(err, decoded) {
    if (err)
    return res.status(401).send({ 'error': 'Failed to authenticate token.' });
      
    // if everything good, save to request for use in other routes
    req.user_id = decoded.id;

    console.log("token ok: ")
    console.log(token)
    next();
  });
}

module.exports = verifyToken;