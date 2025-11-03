# Puddingstone Club Website

A web application for Little Compton, Rhode Island's premier social supper club, designed to help busy members coordinate schedules and plan gatherings.

## 🍷 Features

### Current (v1.0)
- **Interactive Event Scheduler**: Members can select available dates on a visual calendar
- **Automatic Best Date Calculation**: Shows which dates work for the most members  
- **Member Management**: Track who has submitted availability
- **Local Storage**: All data persists between sessions
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **No Backend Required**: Runs entirely in the browser

## 🚀 Getting Started

### Quick Start
Visit the live site: **[https://LewChew.github.io/puddingstone-club/](https://LewChew.github.io/puddingstone-club/)**

Or run locally:
1. Clone the repository:
   ```bash
   git clone https://github.com/LewChew/puddingstone-club.git
   cd puddingstone-club
   ```

2. Open `index.html` in your browser

### Development Setup

For local development with live reload:
```bash
# Using Python
python -m http.server 8000

# Using Node.js  
npx http-server

# Then visit http://localhost:8000
```

## 💻 Development Workflow

### Making Changes
```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes to index.html
# Test locally

# Commit and push
git add .
git commit -m "Add: description" 
git push origin feature/your-feature
```

## 🎯 Roadmap

### v1.1 (Next Release)
- [ ] Email notifications for event confirmations
- [ ] Export calendar events to .ics format
- [ ] Dark mode support

### v1.2
- [ ] Event details and menu planning section
- [ ] Photo gallery from past gatherings
- [ ] Member profiles and dietary preferences

### v2.0
- [ ] Backend integration for multi-device sync
- [ ] RSVP system for confirmed events
- [ ] Integration with Google Calendar/Outlook
- [ ] Email reminders

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 Technical Details

The application stores member availability in localStorage:
```javascript
{
  "memberName": ["2024-01-15", "2024-01-16", "2024-01-20"],
  "anotherMember": ["2024-01-16", "2024-01-18", "2024-01-20"]
}
```

To clear data for testing, open browser console:
```javascript
localStorage.removeItem('puddingstoneAvailability');
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Puddingstone Club members for their feedback
- Little Compton, RI community
- All contributors to this project

---

Made with ❤️ for the Puddingstone Club, Little Compton, Rhode Island