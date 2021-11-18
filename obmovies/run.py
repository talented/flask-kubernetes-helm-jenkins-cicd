from obmovies.factory import create_app

import os
import configparser


config = configparser.ConfigParser()
config.read(os.path.abspath(os.path.join(".ini")))

if __name__ == "__main__":
    app = create_app()
    app.config['DEBUG'] = True
    app.config['MOVIES_DB_URI'] = config['PROD']['MOVIES_DB_URI']
    app.config['MOVIES_NS'] = config['PROD']['MOVIES_NS']
    app.config['SECRET_KEY'] = config['PROD']['SECRET_KEY']
    app.config['MONGO_POOLSIZE'] = config['PROD']['MONGO_POOLSIZE']
    app.config['MONGO_TIMEOUTMS'] = config['PROD']['MONGO_TIMEOUTMS']

    app.run(host='0.0.0.0')

else:
    gunicorn_app = create_app()
    gunicorn_app.config['DEBUG'] = False
    gunicorn_app.config['MOVIES_DB_URI'] = config['PROD']['MOVIES_DB_URI']
    gunicorn_app.config['MOVIES_NS'] = config['PROD']['MOVIES_NS']
    gunicorn_app.config['SECRET_KEY'] = config['PROD']['SECRET_KEY']
    gunicorn_app.config['MONGO_POOLSIZE'] = config['PROD']['MONGO_POOLSIZE']
    gunicorn_app.config['MONGO_TIMEOUTMS'] = config['PROD']['MONGO_TIMEOUTMS']
