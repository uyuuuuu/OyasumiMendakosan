let scene = 0;
let mode = 0;
let imgSun, imgRain, imgStart, imgAwa;
let sum, ringNum, maxRing = 10;
let tensu = new Array(maxRing).fill(false);
let inRing = false, finish = false;
let bubbleOver = false, bubbleUnder = false;
let mendako;
let ring = new Array(maxRing);

function preload() {
    imgSun = loadImage('./data/sun.JPG');
    imgRain = loadImage('./data/rain.JPG');
    imgStart = loadImage('./data/start.JPG');
    imgAwa = loadImage('./data/awa.PNG');
}

function setup() {
    createCanvas(600, 600);
    ringNum = 1;
    mendako = new Mendako(60, 60);
    for (let i = 0; i < maxRing; i++) {
        ring[i] = new Ring(width + 55, random(70, height - 70));
    }
}

function draw() {
    switch (scene) {
        case 0:
            image(imgStart, 0, 0);
            if (keyIsPressed && key === 's') {
                mode = 1;
                scene = 1;
            } else if (keyIsPressed && key === 'r') {
                mode = 2;
                scene = 1;
            }

            mendako = new Mendako(60, 60);
            for (let i = 0; i < maxRing; i++) {
                ring[i] = new Ring(width + 55, random(70, height - 70));
                tensu[i] = false;
            }
            ringNum = 1;
            break;

        case 1:
            tint(255, 130);
            sum = 0;
            if (mode === 1) {
                image(imgSun, 0, 0);
            } else if (mode === 2) {
                image(imgRain, 0, 0);
            }
            image(imgAwa, 0, 0);

            for (let i = 0; i < ringNum; i++) {
                ring[i].move();
                ring[i].drawRingB();
            }
            mendako.move();
            mendako.drawMendako();
            for (let i = 0; i < ringNum; i++) {
                ring[i].drawRingF();
            }

            for (let i = 0; i < ringNum; i++) {
                getPoint(mendako.getX(), mendako.getY(), ring[i].getX(), ring[i].getY(), ring[i].getDX());
                attack(mendako.getX(), mendako.getY(), ring[i].getX(), ring[i].getY(), ring[i].getDX());
                if (inRing) {
                    tensu[i] = true;
                    inRing = false;
                }
                if (tensu[i]) {
                    sum++;
                }
            }

            viewPoint();

            if (finished()) {
                fill(255);
                noStroke();
                textSize(100);
                if (sum < maxRing) {
                    text('Score=' + sum, 130, 320);
                } else if (sum == maxRing) {
                    text('FullCombo!!', 50, 320);
                }
                textSize(60);
                text('press space', 150, 420);
                if (keyIsPressed && key === ' ') {
                    scene = 0;
                    mode = 0;
                }
            }
            break;
    }
}

function getPoint(mx, my, rx, ry, d) {
    if (rx - d / 4 <= mx && mx <= rx + d / 4 && my > ry - 3 && my < ry + 3) {
        inRing = true;
    }
}

function attack(mx, my, rx, ry, d) {
    let right, left, over, under;
    over = ry - 25 < my && my < ry - 5;
    under = ry + 5 < my && my < ry + 25;

    right = rx - d < mx && mx < rx - d / 4;
    left = rx + d / 4 < mx && mx < rx + d;
    if ((right || left) && over) {
        bubbleOver = true;
    } else if ((right || left) && under) {
        bubbleUnder = true;
    }
}

function viewPoint() {
    fill(25, 40, 140);
    noStroke();
    textSize(60);
    text(sum, width - 60, 60);
}

function finished() {
    return -30 >= ring[maxRing - 1].getX();
}

class Mendako {
    constructor(x, y) {
        this.gravity = 2.0 / 60;
        this.x = x;
        this.y = y;
        this.dx = 60;
        this.dy = 55;
        this.vy = 0;
        this.up = false;
        this.ear = [];
        this.foot = [];
        let r = this.dx / 2;
        let EarOff = r / 1.4;
        this.ear.push(new Ear(x, y, -EarOff, -EarOff));
        this.ear.push(new Ear(x, y, EarOff, -EarOff));
        let outOffX = this.dx / 2.3;
        let inOffX = this.dx / 5;
        let outOffY = r / 1.8;
        let inOffY = r / 1.5;
        this.foot.push(new Foot(x, y, -outOffX, outOffY));
        this.foot.push(new Foot(x, y, -inOffX, inOffY));
        this.foot.push(new Foot(x, y, inOffX, inOffY));
        this.foot.push(new Foot(x, y, outOffX, outOffY));
        let eyeOffX = r / 3;
        this.eye = new Eye(x, y, eyeOffX);
        this.awa = new Awa(x, y);
    }

    getX() {
        return this.x;
    }

    getY() {
        return this.y;
    }

    drawMendako() {
        this.awa.drawAwa();
        noStroke();
        for (let ear of this.ear) {
            ear.drawEar();
        }
        for (let foot of this.foot) {
            foot.drawFoot();
        }
        fill(221, 122, 163);
        ellipse(this.x, this.y, this.dx, this.dy);
        this.eye.drawEye();
    }

    move() {
        if (mouseIsPressed) {
            this.up = true;
            if (this.vy < -3) {
                this.vy -= 0.006;
            } else {
                this.vy -= 0.2;
            }
        } else {
            this.up = false;
        }

        if (this.y < -50) {
            this.vy *= -1;
        } else if (this.y > height + 50) {
            this.vy = -3;
        }

        if (bubbleOver) {
            this.vy = -2;
            bubbleOver = false;
            bubbleUnder = false;
        } else if (bubbleUnder) {
            this.vy = 2;
            bubbleOver = false;
            bubbleUnder = false;
        }

        this.vy += this.gravity;
        this.y += this.vy;
        for (let ear of this.ear) {
            ear.moveEar(this.x, this.y);
        }
        for (let foot of this.foot) {
            foot.moveFoot(this.x, this.y, this.up);
        }
        this.eye.moveEye(this.x, this.y);
        this.awa.moveAwa(this.y);
    }
}

class Eye {
    constructor(baseX, baseY, offX) {
        this.d = 5;
        this.offX = offX;
        this.rx = baseX - offX;
        this.lx = baseX + offX;
        this.y = baseY;
    }

    drawEye() {
        stroke(50);
        strokeWeight(3);
        line(this.rx, this.y, this.rx - this.d, this.y);
        line(this.lx, this.y, this.lx + this.d, this.y);
    }

    moveEye(baseX, baseY) {
        this.rx = baseX - this.offX;
        this.lx = baseX + this.offX;
        this.y = baseY;
    }
}

class Ear {
    constructor(baseX, baseY, offX, offY) {
        this.d = 20;
        this.offX = offX;
        this.offY = offY;
        this.x = baseX + offX;
        this.y = baseY + offY;
    }

    drawEar() {
        fill(221, 122, 163);
        ellipse(this.x, this.y, this.d, this.d);
    }

    moveEar(baseX, baseY) {
        this.x = baseX + this.offX;
        this.y = baseY + this.offY;
    }
}

class Foot {
    constructor(baseX, baseY, offX, offY) {
        this.d = 20;
        this.offX = offX;
        this.offY = offY;
        this.x = baseX + offX;
        this.y = baseY + offY;
        this.upfoot = 3;
    }

    drawFoot() {
        fill(221, 122, 163);
        ellipse(this.x, this.y, this.d, this.d);
    }

    moveFoot(baseX, baseY, up) {
        if (up) {
            this.y = baseY + this.offY - this.upfoot;
        } else {
            this.y = baseY + this.offY;
        }
        this.x = baseX + this.offX;
    }
}

class Awa {
    constructor(x, my) {
        this.x = x;
        this.my = my;
        this.vy = 50;
        this.y = my;
        this.dx = 30;
        this.dy = 10;
    }

    moveAwa(my) {
        if (this.y < my) {
            this.y++;
        }
        if (this.y > my) {
            this.y--;
        }
    }

    drawAwa() {
        strokeWeight(4);
        stroke(255, 255, 255, 60);
        ellipse(this.x, this.y, this.dx, this.dy);
    }
}

class Ring {
    constructor(x, y) {
        this.fuwa = 1;
        this.df = 0.2;
        this.x = x;
        this.y = y;
        this.dx = 100;
        this.dy = 20;
        this.newsw = false;
        if (mode === 1) {
            this.speed = 1;
            this.maxfuwa = 4;
        } else if (mode === 2) {
            this.speed = 1.8;
            this.maxfuwa = 7;
        }
    }

    getX() {
        return this.x;
    }

    getY() {
        return this.y;
    }

    getDX() {
        return this.dx;
    }

    move() {
        this.x -= this.speed;
        if (this.fuwa > this.maxfuwa || this.fuwa < -1 * this.maxfuwa) {
            this.df *= -1;
        }
        this.fuwa += this.df;

        if (width / 2 < this.x) {
            this.newsw = false;
        }
        if (this.newsw === false && width / 2 >= this.x && ringNum < maxRing) {
            ringNum++;
            this.newsw = true;
        }
    }

    drawRingB() {
        noFill();
        strokeWeight(10);
        this.ringColor();
        arc(this.x, this.y + this.fuwa, this.dx, this.dy, PI, TWO_PI);
    }

    drawRingF() {
        noFill();
        strokeWeight(10);
        this.ringColor();
        arc(this.x, this.y + this.fuwa, this.dx, this.dy, 0, PI);
    }

    ringColor() {
        if (mode === 1) {
            if (this.y < height * 2 / 3) {
                stroke(223, 230, 237);
            } else if (this.y >= height * 2 / 3) {
                stroke(144, 166, 216);
            }
        } else if (mode === 2) {
            if (this.y < height / 2) {
                stroke(174, 190, 219);
            } else if (this.y >= height / 2) {
                stroke(134, 159, 200);
            }
        }
    }
}
