package main

import (
	"bufio"
	_ "fmt"
	"github.com/tarm/serial"
	"log"
	"os"
	"os/exec"
	"strconv"
	"time"
)

func main() {
	log.Printf("----- start -----")
	//	c := &serial.Config{Name: "/dev/ttyUSB0", Baud: 9600}
	c := new(serial.Config)
	c.Name = "/dev/ttyAMA0"
	c.Baud = 9600

	s, err := serial.OpenPort(c)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("%V", s)

	//----------------------------------
	for {
		reader := bufio.NewReader(s)
		line, _, err := reader.ReadLine()
		if err != nil {
			panic(err)
		}
		log.Printf("-->%v<--", line)

		//----------------------------------
		in := string(line[:])

		//---------------
		// mode or code
		//--------------
		res := ExecMode(in)
		//res := ExecCode(code)

		log.Printf("-->%v<--", res)

		n2, err := s.Write([]byte(res + "\n"))

		if err != nil {
			log.Fatal(err)
		}
		log.Printf("%V", n2)
	}
}

func ExecCode(code string) string {
	filepath := "/tmp/" + strconv.Itoa(int(time.Now().Unix())) + "__ip.sh"
	SaveFile(filepath, code)
	r, _ := CmdExec(exec.Command("bash", filepath))
	DeleteFile(filepath)
	return r
}

//-------------------------------------
func CmdExec(cmd *exec.Cmd) (string, error) {
	out, error := cmd.Output()

	log.Printf("~~=~=~=~=~=~=")
	log.Printf("cmd %v", cmd)
	//  log.Printf("out %v", out)
	log.Printf("error %v", error)
	log.Printf("~~=~=~=~=~=~=")

	return string(out), error
}

//-------------------------------------
func SaveFile(filePath string, contents string) error {
	file, err := os.OpenFile(filePath, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0755)
	defer func() { file.Close() }()
	if err != nil {
		log.Println(err)
	}
	if _, err := file.WriteString(contents); err != nil {
		log.Println(err)
		return err
	}
	return nil
}

func DeleteFile(filePath string) error {
	return os.Remove(filePath)
}

//-------------------------------------
func ExecMode(mode string) string {
	log.Printf(mode)

	res := "1:  ip\n"
	res += "2:  ip a add\n"
	res += "11:  hostname\n"
	res += "91: shutdown\n"
	res += "92: reboot\n"

	switch mode {
	case "1":
		filepath := "/tmp/" + strconv.Itoa(int(time.Now().Unix())) + "__ip.sh"
		SaveFile(filepath, "ip a s |grep inet |grep -v 127.0.0.1\n")
		r, _ := CmdExec(exec.Command("bash", filepath))
		DeleteFile(filepath)
		return r
	case "2":
		filepath := "/tmp/" + strconv.Itoa(int(time.Now().Unix())) + "__ip_add.sh"
		SaveFile(filepath, "ip a add 192.168.1.123/24 dev eth0 \n")
		r, _ := CmdExec(exec.Command("bash", filepath))
		DeleteFile(filepath)
		return r
	case "11":
		r, _ := CmdExec(exec.Command("hostname"))
		return r
	case "91":
		r, _ := CmdExec(exec.Command("shutdown"))
		return r
	case "92":
		r, _ := CmdExec(exec.Command("reboot"))
		return r

	case "99":
		return "ok"
	default:
		return res
	}
	return res
}
