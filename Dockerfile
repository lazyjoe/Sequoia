FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    git \
    pkg-config \
    libfreetype6-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install TA-Lib from source with specific compatibility patches for ARM64
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz && \
    tar -xzf ta-lib-0.4.0-src.tar.gz && \
    cd ta-lib/ && \
    # Fix for ARM64
    sed -i.bak "s|0.00000001|0.000000000000000001 |g" src/ta_func/ta_utility.h && \
    # Update config files to recognize ARM64 architecture
    wget -q 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' -O config.guess && \
    wget -q 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' -O config.sub && \
    chmod +x config.guess config.sub && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf ta-lib ta-lib-0.4.0-src.tar.gz

# Install numpy with a specific version compatible with TA-Lib Python wrapper
RUN pip install --no-cache-dir numpy==1.23.5

# Install the TA-Lib Python wrapper
RUN pip install --no-cache-dir ta-lib==0.4.24

# Clone the Sequoia repository
# RUN git clone https://github.com/sngyai/Sequoia.git

# Set working directory
WORKDIR /app/Sequoia

# Install Python dependencies in the correct order
RUN pip install --no-cache-dir pandas==1.5.3 matplotlib==3.7.1 \
    backtrader==1.9.76.123 empyrical==0.5.5 \
    logbook==1.5.3 scipy statsmodels \
    scikit-learn==1.3.0 pandas-datareader==0.10.0 \
    requests==2.28.2 sqlalchemy==2.0.15 pymysql==1.1.0 \
    lxml==4.9.2 beautifulsoup4==4.12.2 \
    python-dateutil==2.8.2 \
    retrying==1.3.4 tabulate==0.9.0 pyecharts==2.0.3 \
    pyyaml==6.0 schedule && \
    pip install --no-cache-dir websocket-client==0.57.0 && \
    pip install --no-cache-dir tushare==1.2.89 && \
    pip install --no-cache-dir akshare --upgrade && \
    pip install --no-cache-dir WxPusher

# Create config file
# RUN cp config.yaml.example config.yaml

# Set the entry point with the full path to main.py
ENTRYPOINT ["python", "/app/Sequoia/main.py"]

# podman run -it --rm -v ~/Code/python/Sequoia:/app/Sequoia -v ~/Code/python/Sequoia/config.yaml.example:/app/Sequoia/config.yaml sequoia