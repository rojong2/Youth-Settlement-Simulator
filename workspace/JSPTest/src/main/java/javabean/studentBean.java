package javabean;

public class studentBean {
	private String id;
	private String name;
	private int num;
	private int birth;
	private String pw;
	private String mail;
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getNum() {
		return num;
	}
	public void setNum(int num) {
		this.num = num;
	}
	public int getBirth() {
		return birth;
	}
	public void setBirth(int birth) {
		this.birth = birth;
	}
	public String getPw() {
		return pw;
	}
	public void setPw(String pw) {
		this.pw = pw;
	}
	public String getMail() {
		return mail;
	}
	public void setMail(String mail) {
		this.mail = mail;
	}
	public int getAge() {
		int age = 0;
		if (birth == 1995)
			age = 31;
		else if (birth == 1996)
			age = 30;
		else if (birth == 1997)
			age = 29;
		else if (birth == 1998)
			age = 28;
		else if (birth == 1999)
			age = 27;
		return age;
	}
}
